//
//  LibraryFinder.swift
//  Ergo
//
//  Created by Adon Omeri on 11/11/2026.
//

import ErgoCatalog
import Foundation
import FoundationModels

/// Finds library entries from a description in someone's own words, with the model on the device.
///
/// The model never names an entry itself. It says what to search for, the library's own search finds the candidates,
/// and the model picks from those, so every result is a real entry. Every call is a session of its own, so none
/// carries another's context, and all a call is given of an entry is its name, its kind and its summary.
@Observable
final class LibraryFinder {
	enum Step: Equatable {
		case naming
		case searching
		case reading(Int, of: Int)
		case ranking
	}

	enum State: Equatable {
		case idle
		case working(Step)
		case found(Answer)
		case nothing
	}

	/// What's shown for a description: the model talking the person through what it found, or only what the search found
	struct Answer: Equatable {
		/// What it most likely is, said to the person. Empty for a plain search.
		var opening = ""
		var matches: [Match] = []
		/// How to tell the matches apart. Empty for a plain search.
		var closing = ""
		/// False when these are only what the library's search found
		var byModel = true
		/// True while the model is still writing it
		var isWriting = false
	}

	struct Match: Identifiable, Hashable {
		let category: LibraryContent
		let entryID: String
		let name: String
		let summary: String
		/// How the model says it shows up in what was described. Nil for a plain search match.
		let reason: String?

		var id: String {
			"\(category.rawValue)/\(entryID)"
		}
	}

	private(set) var state = State.idle

	/// False when the device can't run the model, it's turned off, or it's still downloading
	static var isModelAvailable: Bool {
		SystemLanguageModel.default.isAvailable
	}

	// MARK: - Limits

	// The model's context is small, so everything it's sent has a ceiling.

	/// The most of a description that's read
	static let descriptionLimit = 600
	private static let termLimit = 6
	private static let candidateLimit = 32
	private static let batchSize = 8
	private static let summaryLimit = 160
	private static let finalistLimit = 8
	/// Left free in the context for the reply
	private static let replyReserve = 400

	// MARK: - find

	func find(_ description: String) async {
		let description = String(description.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Self.descriptionLimit))
		guard !description.isEmpty else {
			state = .idle
			return
		}

		do {
			guard Self.isModelAvailable else {
				state = .working(.searching)
				try await finish(plain: LibraryFinderSearch.plain(description))
				return
			}

			state = .working(.naming)
			let terms = await terms(for: description)
			try Task.checkCancellation()

			state = .working(.searching)
			let candidates = await LibraryFinderSearch.candidates(terms: terms, description: description, limit: Self.candidateLimit)
			guard !candidates.isEmpty else {
				state = .nothing
				return
			}

			var finalists: [LibraryEntryText] = []
			var read = 0
			for batch in candidates.chunked(into: Self.batchSize) {
				try Task.checkCancellation()
				state = .working(.reading(read + batch.count, of: candidates.count))
				finalists += await picks(from: batch, for: description)
				read += batch.count
			}
			try Task.checkCancellation()

			guard !finalists.isEmpty else {
				// The model liked none of them, so what the search liked best is still worth showing
				try finish(plain: Array(candidates.prefix(5)))
				return
			}

			state = .working(.ranking)
			try await answer(with: Array(finalists.prefix(Self.finalistLimit)), for: description)
		} catch {
			state = .idle
		}
	}

	func reset() {
		state = .idle
	}

	private func finish(plain entries: [LibraryEntryText]) throws {
		try Task.checkCancellation()
		let matches = entries.compactMap { Self.match($0, reason: nil) }
		state = matches.isEmpty ? .nothing : .found(Answer(matches: matches, byModel: false))
	}

	// MARK: - The calls

	/// What to search the library for. Without the model's answer, the description's own words are still searched.
	private func terms(for description: String) async -> [String] {
		let session = LanguageModelSession(instructions: Self.termsInstructions)
		let reply = try? await session.respond(
			to: "Description:\n\(description)",
			generating: LibraryFinderTerms.self,
			options: Self.options
		)
		return Array((reply?.content.terms ?? []).prefix(Self.termLimit))
	}

	/// Which of a few entries fit. A batch that won't fit the context is read as two halves.
	private func picks(from batch: [LibraryEntryText], for description: String) async -> [LibraryEntryText] {
		let prompt = Self.prompt(batch, description: description)
		guard await fits(Self.picksInstructions + prompt) else {
			guard batch.count > 1 else { return [] }
			let half = batch.count / 2
			let first = await picks(from: Array(batch[..<half]), for: description)
			return await first + picks(from: Array(batch[half...]), for: description)
		}

		let session = LanguageModelSession(instructions: Self.picksInstructions)
		let reply = try? await session.respond(to: prompt, generating: LibraryFinderPicks.self, options: Self.options)
		var picked: [LibraryEntryText] = []
		for number in reply?.content.numbers ?? [] where batch.indices.contains(number - 1) {
			let entry = batch[number - 1]
			if !picked.contains(entry) {
				picked.append(entry)
			}
		}
		return picked
	}

	/// The model talking the person through the finalists, shown as it's written. Without its answer the finalists are
	/// shown as the search had them.
	private func answer(with finalists: [LibraryEntryText], for description: String) async throws {
		let unranked = Answer(matches: finalists.compactMap { Self.match($0, reason: nil) })
		let prompt = Self.prompt(finalists, description: description)
		guard await fits(Self.answerInstructions + prompt) else {
			state = .found(unranked)
			return
		}

		var answer = Answer(isWriting: true)
		do {
			let session = LanguageModelSession(instructions: Self.answerInstructions)
			for try await snapshot in session.streamResponse(to: prompt, generating: LibraryFinderAnswer.self, options: Self.options) {
				answer.opening = snapshot.content.opening ?? ""
				answer.closing = snapshot.content.closing ?? ""
				answer.matches = Self.matches(snapshot.content.choices ?? [], from: finalists)
				state = .found(answer)
			}
		} catch {
			// What was written before it stopped is kept
			try Task.checkCancellation()
		}

		answer.isWriting = false
		state = .found(answer.matches.isEmpty ? unranked : answer)
	}

	private static func matches(_ choices: [LibraryFinderChoice.PartiallyGenerated], from finalists: [LibraryEntryText]) -> [Match] {
		var matches: [Match] = []
		for choice in choices {
			guard
				let number = choice.number, finalists.indices.contains(number - 1),
				let match = match(finalists[number - 1], reason: choice.explanation),
				!matches.contains(where: { $0.id == match.id })
			else {
				continue
			}
			matches.append(match)
		}
		return matches
	}

	private func fits(_ text: String) async -> Bool {
		let model = SystemLanguageModel.default
		// If it can't be counted, the call is tried anyway, and a call that fails is only skipped
		guard let count = try? await model.tokenCount(for: text) else {
			return true
		}
		return count + Self.replyReserve <= model.contextSize
	}

	// MARK: - What the model is told

	private static let options = GenerationOptions(samplingMode: .greedy)

	private static let termsInstructions = """
	You help someone find the name for a reasoning mistake or a thinking habit, in a library of logical fallacies and \
	cognitive biases. They describe it in their own words. Often they describe a situation, like something a friend said, \
	an ad, or a habit of their own, rather than the idea itself.
	Reply with what to search the library for. First, the usual names of the fallacies or biases it could be, as they'd \
	appear in a textbook. Then a few plain keywords for what's going on. Keep every term to three words or fewer.
	For example, "my brother said I can't tell him to exercise because I don't" could be: tu quoque, ad hominem, \
	hypocrisy. "I keep watching a bad film because I paid for the ticket" could be: sunk cost fallacy, already paid, \
	wasted money.
	"""

	private static let picksInstructions = """
	You match a description to entries in a library of fallacies and biases. You get a description in someone's own \
	words, often of a situation, and a numbered list of entries. Reply with the numbers of the entries that would help \
	put a name to what's going on in that situation, including close ones. Leave out entries that only share a word with \
	it. Reply with no numbers when none fit.
	"""

	private static let answerInstructions = """
	You help someone put a name to something they've noticed. You get their description, in their own words, and a \
	numbered list of library entries that could be it. Talk to them directly, as "you", in plain, warm and friendly \
	language, the way a well-read friend would. Use short sentences and everyday words. No lists, headings or markdown.
	First say what it most likely is, and why, pointing at what they actually described.
	Then give the entries that fit, best first, and leave out the ones that don't. For each one, say how it shows up in \
	what they described. Don't repeat the entry's definition: tie it to their own words.
	Then finish with how to tell these apart, or with what to watch for next time.
	Be fair: describe what was said or done, never call anyone stupid or a liar, and mention it when the point might \
	still have something to it.
	"""

	private static func prompt(_ entries: [LibraryEntryText], description: String) -> String {
		var lines = ["Description:", description, "", "Entries:"]
		for (index, entry) in entries.enumerated() {
			lines.append("\(index + 1). \(entry.name) (\(kind(of: entry))): \(entry.summary.prefix(summaryLimit))")
		}
		return lines.joined(separator: "\n")
	}

	private static func kind(of entry: LibraryEntryText) -> String {
		switch LibraryContent(rawValue: entry.category) {
			case .biases: "bias"
			case .fallacies: "fallacy"
			case nil: entry.category
		}
	}

	private static func match(_ entry: LibraryEntryText, reason: String?) -> Match? {
		guard let category = LibraryContent(rawValue: entry.category) else { return nil }
		return Match(category: category, entryID: entry.id, name: entry.name, summary: entry.summary, reason: reason)
	}
}

// MARK: - What the model replies with

@Generable
nonisolated struct LibraryFinderTerms {
	@Guide(description: "Names of what this could be, and short keyword phrases to search for", .count(1 ... 6))
	var terms: [String]
}

@Generable
nonisolated struct LibraryFinderPicks {
	@Guide(description: "The numbers of the entries that are what the person describes. Empty when none are.")
	var numbers: [Int]
}

@Generable
nonisolated struct LibraryFinderAnswer {
	@Guide(description: "One or two sentences to the person: what they're describing most likely is, and why")
	var opening: String

	@Guide(description: "The entries that fit, best first", .maximumCount(4))
	var choices: [LibraryFinderChoice]

	@Guide(description: "One sentence to the person on how to tell these apart, or what to watch for")
	var closing: String
}

@Generable
nonisolated struct LibraryFinderChoice {
	@Guide(description: "The entry's number in the list")
	var number: Int

	@Guide(description: "One or two sentences to the person on how this shows up in what they described")
	var explanation: String
}

// MARK: - Searching

/// The library's own search, off the main actor, since the first use reads every entry
nonisolated enum LibraryFinderSearch {
	/// Words that say nothing about what's being described, so they'd match almost every summary
	private static let fillerWords: Set<String> = [
		"about", "after", "again", "also", "always", "because", "been", "being", "does", "doing", "else", "even", "every",
		"from", "have", "having", "into", "just", "like", "more", "most", "much", "must", "only", "other", "over", "really",
		"same", "should", "some", "something", "someone", "such", "than", "that", "their", "them", "then", "there", "these",
		"they", "thing", "things", "this", "those", "very", "what", "when", "where", "which", "while", "will", "with",
		"would", "your",
	]

	/// What each term finds, taken a place at a time so no one term crowds out the others, then what the description's
	/// own words find
	@concurrent
	static func candidates(terms: [String], description: String, limit: Int) async -> [LibraryEntryText] {
		guard let catalog = LibraryCatalog.shared else { return [] }

		var lists = terms.map { catalog.search($0, limit: 6) }
		lists.append(catalog.search(keywords(in: description), limit: 8))

		var found: [LibraryEntryText] = []
		for place in 0 ..< (lists.map(\.count).max() ?? 0) {
			for list in lists where place < list.count && !found.contains(list[place]) {
				found.append(list[place])
			}
		}
		return Array(found.prefix(limit))
	}

	@concurrent
	static func plain(_ description: String, limit: Int = 10) async -> [LibraryEntryText] {
		LibraryCatalog.shared?.search(keywords(in: description), limit: limit) ?? []
	}

	private static func keywords(in description: String) -> String {
		description.lowercased()
			.split { !$0.isLetter && !$0.isNumber }
			.map(String.init)
			.filter { $0.count > 3 && !fillerWords.contains($0) }
			.joined(separator: " ")
	}
}

private nonisolated extension Array {
	func chunked(into size: Int) -> [[Element]] {
		stride(from: 0, to: count, by: size).map { Array(self[$0 ..< Swift.min($0 + size, count)]) }
	}
}
