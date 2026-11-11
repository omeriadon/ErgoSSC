//
//  Defaults.swift
//  Ergo
//
//  Created by Adon Omeri on 2/11/2026.
//

import Defaults
import ErgoLogic
import Foundation

// MARK: - What the person made

extension Defaults.Keys {
	static let bookmarks = Key<Set<CatalogReference>>(
		"bookmarks",
		default: []
	)

	static let logicLetters = Key<[String]>("logicLetters", default: LogicLetters.defaults)

	/// Saved through `BoardStore`. Drafts aren't in here.
	static let boards = Key<[Board]>("boards", default: [])

	/// Saved through `ScratchpadStore`. Drafts aren't in here.
	static let scratchpads = Key<[LogicScratchpad]>("scratchpads", default: [])

	static let ditherEnabled = Key<Bool>("ditherEnabled", default: true)

	static let hapticsEnabled = Key<Bool>("hapticsEnabled", default: true)

	/// Which categories the item of the day draws from. Empty means all. Kept sorted.
	static let itemOfTheDayCategories = Key<[String]>("itemOfTheDayCategories", default: [])
}

// MARK: - Where the app was left

extension Defaults.Keys {
	static let selectedTab = Key<AppTab>("selectedTab", default: .board)

	static let libraryPath = Key<[LibraryRoute]>("libraryPath", default: [])

	static let presentedSheet = Key<AppSheet?>("presentedSheet", default: nil)

	static let boardSheet = Key<BoardSheet?>("boardSheet", default: nil)

	static let logicSheet = Key<LogicSheet?>("logicSheet", default: nil)

	static let libraryGeneralSearchText = Key<String>("libraryGeneralSearchText", default: "")

	static let currentBoardID = Key<UUID?>("currentBoardID", default: nil)

	static let pinnedBoards = Key<Set<UUID>>("pinnedBoards", default: [])
	static let archivedBoards = Key<Set<UUID>>("archivedBoards", default: [])

	static let currentScratchpadID = Key<UUID?>("currentScratchpadID", default: nil)

	static let logicPath = Key<[LogicRoute]>("logicPath", default: [])

	static let lastIndexedVersion = Key<String>(
		"lastIndexedVersion",
		default: ""
	)

	/// The course lessons finished
	static let logicCourseFinished = Key<Set<String>>("logicCourseFinished", default: [])
}
