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
/// The catalog is small, so one call is given every entry, numbered, and picks from them. The model never names an
/// entry itself, so every result is a real one, and it may pick none.
@Observable
final class LibraryFinder {
	enum State: Equatable {
		case idle
		case working
		case found(Answer)
		/// Nothing in the catalog fits, which is a normal answer
		case nothing
		/// The model failed or declined
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
		let summary: String
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
	private static let summaryLimit = 200
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
		let prompt = Self.prompt(entries, description: description)
		guard !entries.isEmpty, await fits(Self.instructions + prompt) else {
			state = .failed
			return
		}

		state = .working
		var answer = Answer()
		do {
			let session = LanguageModelSession(instructions: Self.instructions)
			for try await snapshot in session.streamResponse(to: prompt, generating: LibraryFinderAnswer.self, options: Self.options) {
				answer.opening = snapshot.content.opening ?? ""
				answer.matches = Self.matches(snapshot.content.choices ?? [], from: entries)
				if !answer.matches.isEmpty {
					state = .found(answer)
				}
			}
			try Task.checkCancellation()
			state = answer.matches.isEmpty ? .nothing : .found(answer)
		} catch is CancellationError {
			state = .idle
		} catch {
			// What was written before it stopped is kept
			state = answer.matches.isEmpty ? .failed : .found(answer)
		}
	}

	func reset() {
		state = .idle
	}

	private static func matches(_ choices: [LibraryFinderChoice.PartiallyGenerated], from entries: [LibraryEntryText]) -> [Match] {
		var matches: [Match] = []
		for choice in choices {
			guard let number = choice.number, entries.indices.contains(number - 1) else { continue }
			let entry = entries[number - 1]
			guard !matches.contains(where: { $0.id == entry.id }) else { continue }
			matches.append(Match(
				id: entry.id,
				name: entry.name,
				isBias: entry.category == "biases",
				summary: entry.summary,
				reason: choice.explanation
			))
		}
		return matches
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

	private static let instructions = """
	You help someone put a name to something they've noticed, from a short numbered list of fallacies and biases. \
	A fallacy is a mistake in an argument, like a reply that attacks something the other person never said. A bias is \
	a habit of thinking that quietly tilts how someone sees things, like noticing only what agrees with what they \
	already believe.
	People describe situations ("my brother said…", "I keep noticing…"), not definitions, so read what happened, not \
	the words used. Pick only the entries that genuinely describe what happened. Never force a match. The list is \
	small and most descriptions won't be on it, so picking none is normal and often right: then leave the choices \
	empty. Pick at most three, best first.
	Talk to them directly, as "you", in plain, warm language, with short sentences and everyday words. No lists, \
	headings or markdown. The opening is one or two sentences: what it most likely is and why, pointing at what they \
	actually described, or, if nothing fits, a short, kind note saying so. For each pick, say how it shows up in what \
	they described, in your own words, without repeating its definition.
	Be fair: describe what was said or done, never call anyone stupid or a liar, and say so when the point might \
	still have something to it.
	"""

	private static func prompt(_ entries: [LibraryEntryText], description: String) -> String {
		var lines = ["Entries:"]
		for (index, entry) in entries.enumerated() {
			let kind = entry.category == "biases" ? "bias" : "fallacy"
			lines.append("\(index + 1). \(entry.name) (\(kind)): \(entry.summary.prefix(summaryLimit))")
		}
		lines += ["", "Description:", description]
		return lines.joined(separator: "\n")
	}
}

// MARK: - What the model replies with

@Generable
nonisolated struct LibraryFinderAnswer {
	@Guide(description: "One or two sentences to the person: what they're describing most likely is, and why. If nothing on the list fits, say so kindly.")
	var opening: String

	@Guide(description: "Only the entries that genuinely fit what the person describes, best first. Empty if none do.", .maximumCount(3))
	var choices: [LibraryFinderChoice]
}

@Generable
nonisolated struct LibraryFinderChoice {
	@Guide(description: "The entry's number in the list")
	var number: Int

	@Guide(description: "One or two sentences to the person on how this shows up in what they described")
	var explanation: String
}
