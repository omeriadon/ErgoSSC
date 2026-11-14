//
//  LibraryEntryMatcher.swift
//  Squint
//
//  Created by Adon Omeri on 14/11/2026.
//

import Foundation
import FuzzyMatch
import SquintCatalog

/// Finds catalog entries from words: the names the model gives Describe It, and what's typed into the search without
/// the model.
nonisolated enum LibraryEntryMatcher {
	/// A name that's close but not exact has to score at least this much, which is conservative enough that
	/// "slippery slope" never lands on "straw man"
	private static let nameThreshold = 0.8
	/// Shorter names are only matched exactly
	private static let fuzzyNameLength = 5
	private static let suffixes = [" fallacy", " bias", " effect"]

	// MARK: - Names

	/// The entries the names stand for, in the order given, with none twice. A name that isn't one of them is dropped.
	static func entries(named names: [String], in entries: [LibraryEntryText]) -> [LibraryEntryText] {
		var found: [LibraryEntryText] = []
		for name in names {
			if let entry = entry(named: name, in: entries), !found.contains(where: { $0.id == entry.id }) {
				found.append(entry)
			}
		}
		return found
	}

	private static func entry(named name: String, in entries: [LibraryEntryText]) -> LibraryEntryText? {
		let query = normalized(name)
		guard !query.isEmpty else { return nil }

		let keys = entries.map { entry in
			([entry.name] + entry.aliases).map(normalized)
		}
		if let index = keys.firstIndex(where: { $0.contains(query) }) {
			return entries[index]
		}
		guard query.count >= fuzzyNameLength else { return nil }

		let matcher = FuzzyMatcher(config: MatchConfig(
			minScore: nameThreshold,
			algorithm: .editDistance(EditDistanceConfig(maxEditDistance: 1))
		))
		let prepared = matcher.prepare(query)
		var buffer = matcher.makeBuffer()
		var best: (index: Int, score: Double)?
		for (index, entryKeys) in keys.enumerated() {
			for key in entryKeys {
				guard let match = matcher.score(key, against: prepared, buffer: &buffer), match.kind != .acronym else { continue }
				if match.score > (best?.score ?? 0) {
					best = (index, match.score)
				}
			}
		}
		return best.map { entries[$0.index] }
	}

	/// Lowercase words with the punctuation gone, and without a trailing "fallacy", "bias" or "effect"
	private static func normalized(_ text: String) -> String {
		var result = text.lowercased()
			.split(whereSeparator: { !$0.isLetter && !$0.isNumber })
			.joined(separator: " ")
		if let suffix = suffixes.first(where: { result.hasSuffix($0) }) {
			result.removeLast(suffix.count)
		}
		return result
	}

	// MARK: - Search

	/// The entries that fit what was typed, best first, over each one's name, other names and plain description.
	/// Everything, in order, when nothing is typed.
	static func search(_ text: String, in entries: [LibraryEntryText]) -> [LibraryEntryText] {
		let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !text.isEmpty else { return entries }

		let matcher = FuzzyMatcher()
		let prepared = matcher.prepare(text)
		var buffer = matcher.makeBuffer()
		var scored: [(index: Int, score: Double)] = []
		for (index, entry) in entries.enumerated() {
			let fields = [(entry.name, 1.0)] + entry.aliases.map { ($0, 0.9) } + [(entry.plain, 0.5)]
			var best = 0.0
			for (field, weight) in fields {
				if let match = matcher.score(field, against: prepared, buffer: &buffer) {
					best = max(best, match.score * weight)
				}
			}
			if best > 0 {
				scored.append((index, best))
			}
		}
		return scored
			.sorted { $0.score == $1.score ? $0.index < $1.index : $0.score > $1.score }
			.map { entries[$0.index] }
	}
}
