//
//  LibraryFinder.swift
//  Squint
//
//  Created by Adon Omeri on 11/11/2026.
//

import Foundation
import FoundationModels
import SquintCatalog

/// Names what someone describes, with the model on the device.
///
/// It's three steps. The model names what it sees freely, since it knows the usual names far better than it picks from
/// a list. Then each name is mapped to a catalog entry without the model, and a name that isn't one is dropped, so
/// every result is a real one. Then the model explains only those entries.
@Observable
final class LibraryFinder {
	enum State: Equatable {
		case idle
		case working
		case found(Answer)
		/// Nothing in the catalog fits, which is a normal answer
		case nothing
		/// The model failed or declined to name anything
		case failed
	}

	/// The model talking the person through what it found, shown as it's written
	struct Answer: Equatable {
		var opening = ""
		var matches: [Match] = []
	}

	struct Match: Identifiable, Hashable {
		let id: String
		let name: String
		let isBias: Bool
		let plain: String
		/// How the model says it shows up in what was described
		let reason: String?

		var kind: String {
			isBias ? "Bias" : "Fallacy"
		}

		var symbol: String {
			isBias ? "distribute.vertical.center" : "repeat.badge.xmark"
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
	/// Left free in the context for the reply
	private static let replyReserve = 500

	// MARK: - find

	func find(_ description: String) async {
		let description = String(description.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Self.descriptionLimit))
		guard !description.isEmpty else {
			state = .idle
			return
		}

		let entries = LibraryCatalog.shared?.entries ?? []
		let namingInstructions = Self.namingInstructions(entries)
		guard !entries.isEmpty, await fits(namingInstructions + description) else {
			state = .failed
			return
		}

		state = .working
		let names: [String]
		do {
			let session = LanguageModelSession(instructions: namingInstructions)
			names = try await session.respond(to: description, generating: LibraryFinderNames.self, options: Self.options).content.names
			try Task.checkCancellation()
		} catch is CancellationError {
			state = .idle
			return
		} catch {
			state = .failed
			return
		}

		let mapped = LibraryEntryMatcher.entries(named: names, in: entries)
		guard !mapped.isEmpty else {
			state = .nothing
			return
		}
		await explain(mapped, description: description)
	}

	/// Shows the entries, then the model's words on them as they're written. If that fails the entries stay, bare.
	private func explain(_ mapped: [LibraryEntryText], description: String) async {
		var answer = Answer(matches: mapped.map { Self.match($0, reason: nil) })
		state = .found(answer)

		let prompt = Self.explainingPrompt(mapped, description: description)
		guard await fits(Self.explainingInstructions + prompt) else { return }

		do {
			let session = LanguageModelSession(instructions: Self.explainingInstructions)
			for try await snapshot in session.streamResponse(to: prompt, generating: LibraryFinderAnswer.self, options: Self.options) {
				answer.opening = snapshot.content.opening ?? ""
				answer.matches = Self.matches(mapped, explained: snapshot.content.choices ?? [])
				state = .found(answer)
			}
			try Task.checkCancellation()
		} catch is CancellationError {
			state = .idle
		} catch {
			// What was written before it stopped is kept
		}
	}

	func reset() {
		state = .idle
	}

	private static func match(_ entry: LibraryEntryText, reason: String?) -> Match {
		Match(id: entry.id, name: entry.name, isBias: entry.category == "biases", plain: entry.plain, reason: reason)
	}

	/// Every mapped entry, in order, with the words written for it so far
	private static func matches(_ mapped: [LibraryEntryText], explained choices: [LibraryFinderChoice.PartiallyGenerated]) -> [Match] {
		var reasons: [Int: String] = [:]
		for choice in choices {
			if let number = choice.number, let explanation = choice.explanation {
				reasons[number] = explanation
			}
		}
		return mapped.enumerated().map { index, entry in
			match(entry, reason: reasons[index + 1])
		}
	}

	private func fits(_ text: String) async -> Bool {
		let model = SystemLanguageModel.default
		// If it can't be counted, the call is tried anyway
		guard let count = try? await model.tokenCount(for: text) else {
			return true
		}
		return count + Self.replyReserve <= model.contextSize
	}

	// MARK: - What the model is told

	private static let options = GenerationOptions(samplingMode: .greedy)

	/// Squint's own names go in the instructions, so the model uses them when one fits
	private static func namingInstructions(_ entries: [LibraryEntryText]) -> String {
		let names = entries.map { entry in
			entry.aliases.isEmpty ? entry.name : "\(entry.name) [\(entry.aliases.joined(separator: ", "))]"
		}
		return """
		Someone describes a situation they noticed, like something a friend said, an ad, or a habit of their own. Say \
		which logical fallacy or cognitive bias it shows, by its usual name. A fallacy is a mistake in an argument. A \
		bias is a habit of thinking that tilts how someone sees things. Read what actually happened, not the words used.
		Squint covers these: \(names.joined(separator: "; ")). If it's one of these, use that exact name. If it's \
		something else, give its usual name anyway. If nothing in particular is wrong, give no names. Most of the \
		time one name is right.
		"""
	}

	private static let explainingInstructions = """
	Someone described something they noticed, and it's been matched to the numbered fallacies or biases below. Explain \
	each one to them. A fallacy is a mistake in an argument. A bias is a habit of thinking that quietly tilts how \
	someone sees things.
	Talk to them directly, as "you", in plain, warm language, with short sentences and everyday words. No lists, \
	headings or markdown. The opening is one or two sentences: what it most likely is and why, pointing at what they \
	actually described. For each entry, in the order given, say how it shows up in what they described, in your own \
	words, without repeating its definition.
	Be fair: describe what was said or done, never call anyone stupid or a liar, and say so when the point might \
	still have something to it.
	"""

	private static func explainingPrompt(_ entries: [LibraryEntryText], description: String) -> String {
		var lines = ["Entries:"]
		for (index, entry) in entries.enumerated() {
			let kind = entry.category == "biases" ? "bias" : "fallacy"
			lines.append("\(index + 1). \(entry.name) (\(kind)): \(entry.plain)")
		}
		lines += ["", "Description:", description]
		return lines.joined(separator: "\n")
	}
}

// MARK: - What the model replies with

/// What the model sees in the description. `situation` comes first so it reasons before it commits to a name.
@Generable
nonisolated struct LibraryFinderNames {
	@Guide(description: "One plain sentence restating what happened in the description")
	var situation: String

	@Guide(description: "The usual name of the fallacy or bias this is, best first. A second only if it clearly fits too. Empty if it's just a disagreement, a fair point, or nothing specific.", .maximumCount(2))
	var names: [String]
}

@Generable
nonisolated struct LibraryFinderAnswer {
	@Guide(description: "One or two sentences to the person: what they're describing most likely is, and why, pointing at what they described.")
	var opening: String

	@Guide(description: "One for each entry given, in the order given", .maximumCount(2))
	var choices: [LibraryFinderChoice]
}

@Generable
nonisolated struct LibraryFinderChoice {
	@Guide(description: "The entry's number in the list")
	var number: Int

	@Guide(description: "One or two sentences to the person on how this shows up in what they described")
	var explanation: String
}
