//
//  Defaults.swift
//  Ergo
//
//  Created by Adon Omeri on 2/11/2026.
//

import Defaults
import Foundation

// MARK: - What the person made

extension Defaults.Keys {
	/// Which categories the item of the day draws from. Empty means all. Kept sorted.
	static let itemOfTheDayCategories = Key<[String]>("itemOfTheDayCategories", default: [])
}

// MARK: - Lessons

extension Defaults.Keys {
	static let lessonsFinished = Key<Set<Lesson>>("lessonsFinished", default: [])

	/// Each lesson's own state, so it opens where it was left. The types live in the lesson's folder.
	static let behindTheWordsState = Key<BehindTheWordsState>("behindTheWordsState", default: .init())
	static let fairPointState = Key<FairPointState>("fairPointState", default: .init())
	static let biggerPictureState = Key<BiggerPictureState>("biggerPictureState", default: .init())
}

// MARK: - Where the app was left

extension Defaults.Keys {
	static let selectedTab = Key<AppTab>("selectedTab", default: .learn)

	static let libraryPath = Key<[LibraryRoute]>("libraryPath", default: [])

	static let presentedSheet = Key<AppSheet?>("presentedSheet", default: nil)

	static let libraryGeneralSearchText = Key<String>("libraryGeneralSearchText", default: "")

	static let currentBoardID = Key<UUID?>("currentBoardID", default: nil)

	static let pinnedBoards = Key<Set<UUID>>("pinnedBoards", default: [])
	static let archivedBoards = Key<Set<UUID>>("archivedBoards", default: [])

	static let learnPath = Key<[LearnRoute]>("learnPath", default: [])
}
