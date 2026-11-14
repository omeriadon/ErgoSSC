//
//  Defaults.swift
//  Squint
//
//  Created by Adon Omeri on 2/11/2026.
//

import Defaults
import Foundation

// MARK: - Lessons

extension Defaults.Keys {
	static let lessonsFinished = Key<Set<Lesson>>("lessonsFinished", default: [])

	/// The welcome sheet has been closed, so it doesn't show again
	static let hasSeenWelcome = Key<Bool>("hasSeenWelcome", default: false)

	/// Each lesson's own state, so it opens where it was left. The types live in the lesson's folder.
	static let behindTheWordsState = Key<BehindTheWordsState>("behindTheWordsState", default: .init())
	static let fairPointState = Key<FairPointState>("fairPointState", default: .init())
	static let biggerPictureState = Key<BiggerPictureState>("biggerPictureState", default: .init())
	static let luckySocksState = Key<LuckySocksState>("luckySocksState", default: .init())
}

// MARK: - Where the app was left

extension Defaults.Keys {
	static let selectedTab = Key<AppTab>("selectedTab", default: .learn)

	static let libraryPath = Key<[LibraryRoute]>("libraryPath", default: [])

	static let presentedSheet = Key<AppSheet?>("presentedSheet", default: nil)

	static let libraryGeneralSearchText = Key<String>("libraryGeneralSearchText", default: "")

	static let learnPath = Key<[LearnRoute]>("learnPath", default: [])
}
