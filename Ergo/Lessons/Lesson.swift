//
//  Lesson.swift
//  Ergo
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

	var id: Self {
		self
	}

	var number: Int {
		(Self.allCases.firstIndex(of: self) ?? 0) + 1
	}

	var title: String {
		switch self {
			case .behindTheWords: "Behind the words"
			case .fairPoint: "Fair point?"
			case .biggerPicture: "The bigger picture"
		}
	}

	/// The title on its first and last pages
	var pageTitle: String {
		switch self {
			case .behindTheWords: "Behind the words…"
			case .fairPoint: "Fair point?"
			case .biggerPicture: "The bigger picture"
		}
	}

	/// The question the lesson asks, under its title in the list
	var question: String {
		switch self {
			case .behindTheWords: "What does it want you to believe, and what holds it up?"
			case .fairPoint: "Is that reply about what was actually said?"
			case .biggerPicture: "Where did the counting start?"
		}
	}

	/// What it teaches, shown on its card in the list
	var topics: [String] {
		switch self {
			case .behindTheWords: ["Claims", "Reasons", "Filler", "Proof surrogate"]
			case .fairPoint: ["Straw man", "Ad hominem", "False dilemma"]
			case .biggerPicture: ["Cherry-picking", "Back to normal"]
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
		}
	}

	/// The first lesson is always open, and each one after it opens once the one before is finished
	func isUnlocked(finished: Set<Lesson>) -> Bool {
		number == 1 || finished.contains(Self.allCases[number - 2])
	}

	/// Back to the first page, with nothing answered
	@MainActor func startOver() {
		switch self {
			case .behindTheWords: Defaults.reset(.behindTheWordsState)
			case .fairPoint: Defaults.reset(.fairPointState)
			case .biggerPicture: Defaults.reset(.biggerPictureState)
		}
	}

	/// Every lesson back to its first page, and none finished, so only the first is open
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
