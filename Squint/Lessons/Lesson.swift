//
//  Lesson.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import Foundation

/// The lessons on the Learn tab, in order. Each one's pages are in its own folder.
nonisolated enum Lesson: String, Hashable, CaseIterable, Identifiable, Codable, Sendable, Defaults.Serializable {
	case behindTheWords
	case fairPoint
	case biggerPicture
	case luckySocks

	var id: Self {
		self
	}

	var number: Int {
		(Self.allCases.firstIndex(of: self) ?? 0) + 1
	}

	/// On its card, and on its first and last pages
	var title: String {
		switch self {
			case .behindTheWords: "Behind the words…"
			case .fairPoint: "Fair point…"
			case .biggerPicture: "The bigger picture…"
			case .luckySocks: "Lucky socks…"
		}
	}

	/// The question the lesson asks, under its title in the list
	var question: String {
		switch self {
			case .behindTheWords: "What does it want you to believe, and what holds it up?"
			case .fairPoint: "Is that reply about what was actually said?"
			case .biggerPicture: "Where did the counting start?"
			case .luckySocks: "Does it really happen every time?"
		}
	}

	/// What it teaches, shown on its card in the list
	var topics: [String] {
		switch self {
			case .behindTheWords: ["Claims", "Reasons", "Filler", "Proof surrogate"]
			case .fairPoint: ["Straw man", "Ad hominem", "False dilemma"]
			case .biggerPicture: ["Cherry-picking", "Back to normal"]
			case .luckySocks: ["Confirmation bias", "Count the misses"]
		}
	}

	/// The Library entries its summary links to
	var related: [LessonLink] {
		switch self {
			case .behindTheWords:
				[LessonLink(name: "Proof surrogate", id: "proof-surrogate")]
			case .fairPoint:
				[
					LessonLink(name: "Straw man", id: "straw-man"),
					LessonLink(name: "Ad hominem", id: "ad-hominem"),
					LessonLink(name: "False dilemma", id: "false-dilemma"),
				]
			case .biggerPicture:
				[
					LessonLink(name: "Cherry-picking", id: "cherry-picking"),
					LessonLink(name: "Regression fallacy", id: "regression-fallacy"),
				]
			case .luckySocks:
				[
					LessonLink(name: "Confirmation bias", category: .biases, id: "confirmation-bias"),
					LessonLink(name: "Illusory correlation", category: .biases, id: "illusory-correlation"),
				]
		}
	}

	/// Back to the first page, with nothing answered
	@MainActor func startOver() {
		switch self {
			case .behindTheWords: Defaults.reset(.behindTheWordsState)
			case .fairPoint: Defaults.reset(.fairPointState)
			case .biggerPicture: Defaults.reset(.biggerPictureState)
			case .luckySocks: Defaults.reset(.luckySocksState)
		}
	}

	/// Every lesson back to its first page, and none finished
	@MainActor static func resetAll() {
		for lesson in allCases {
			lesson.startOver()
		}
		Defaults.reset(.lessonsFinished)
	}
}

/// A Library entry a lesson links to. Every id must be in the category's JSON.
nonisolated struct LessonLink: Hashable, Sendable {
	let name: String
	var category: LibraryContent = .fallacies
	let id: String
}
