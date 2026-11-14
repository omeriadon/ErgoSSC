//
//  LuckySocksContent.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Foundation

/// One of the four boxes: whether the first thing happened (a row), and whether the second did (a column)
nonisolated enum FourBox: Int, CaseIterable, Codable, Hashable, Sendable {
	/// Socks on, and won
	case both
	/// Socks on, but lost
	case firstOnly
	/// No socks, but won
	case secondOnly
	/// No socks, and lost
	case neither

	init(first: Bool, second: Bool) {
		switch (first, second) {
			case (true, true): self = .both
			case (true, false): self = .firstOnly
			case (false, true): self = .secondOnly
			case (false, false): self = .neither
		}
	}
}

/// What the grid's rows and columns are called
nonisolated struct FourBoxLabels: Hashable, Sendable {
	/// The first row, like "Socks"
	let first: String
	/// The second row, like "No socks"
	let notFirst: String
	/// The first column, like "Won"
	let second: String
	/// The second column, like "Lost"
	let notSecond: String
}

/// How many of something fell in each box
nonisolated struct FourBoxCounts: Hashable, Sendable {
	let both: Int
	let firstOnly: Int
	let secondOnly: Int
	let neither: Int

	subscript(box: FourBox) -> Int {
		switch box {
			case .both: both
			case .firstOnly: firstOnly
			case .secondOnly: secondOnly
			case .neither: neither
		}
	}

	/// How often the second thing happened along with the first, out of every time the first did
	var firstRate: Double {
		Double(both) / Double(max(1, both + firstOnly))
	}

	/// The same, for every time the first didn't happen
	var notFirstRate: Double {
		Double(secondOnly) / Double(max(1, secondOnly + neither))
	}

	/// The two rates differ by at least 20 points
	var holdsUp: Bool {
		abs(firstRate - notFirstRate) >= 0.2
	}
}

/// One game of Jess's season
nonisolated struct LuckySocksGame: Identifiable, Hashable, Sendable {
	let id: Int
	let socks: Bool
	let won: Bool

	var box: FourBox {
		FourBox(first: socks, second: won)
	}
}

/// A claim on page 3, its four boxes, and whether it holds up
nonisolated struct LuckySocksQuizItem: Identifiable, Hashable, Sendable {
	let id: Int
	let claim: String
	let labels: FourBoxLabels
	let counts: FourBoxCounts
	let holdsUp: Bool
	let explanation: String
}

/// Everything lesson 4 says. Every answer is authored here, and every number is counted from the data.
nonisolated enum LuckySocks {
	static let friend = "Jess"

	static let socksMessage = "Every time I wear my lucky socks, we win! 🧦"

	static let sleepMessage = "ok fine 😅 but when I sleep badly I'm grumpy the next day. that one's real"

	static let seasonLabels = FourBoxLabels(first: "Socks", notFirst: "No socks", second: "Won", notSecond: "Lost")

	/// In the order they were played. Four of each kind of win, and two of each kind of loss.
	static let season = games([
		(true, true), (false, true), (true, false), (false, false),
		(true, true), (false, true), (true, true), (false, true),
		(false, false), (true, false), (true, true), (false, true),
	])

	/// The games she remembers: socks on, and won
	static var remembered: Set<Int> {
		Set(season.filter { $0.box == .both }.map(\.id))
	}

	static var seasonCounts: FourBoxCounts {
		counts(season.map(\.box))
	}

	static let seasonLine = "Same either way. Jess isn't lying: the wins in her socks are just the ones she remembers."

	static let sleepLabels = FourBoxLabels(first: "Slept badly", notFirst: "Slept well", second: "Grumpy", notSecond: "Fine")

	/// Jess's last eight days. She remembers the top left: bad sleep, then grumpy.
	static let weekCounts = FourBoxCounts(both: 3, firstOnly: 1, secondOnly: 1, neither: 3)

	static let sleepPrompt = "Jess remembers 3 grumpy days after bad sleep. Is that enough to know? Tap the other boxes to count them too."

	static let sleepLine = "This one holds up. Counting all four boxes is how you can tell."

	static let takeaway = "When something seems to happen every time, count the times it didn't, too."

	static let quiz: [LuckySocksQuizItem] = checked([
		LuckySocksQuizItem(
			id: 0,
			claim: "Every time I wash my car, it rains.",
			labels: FourBoxLabels(first: "Washed car", notFirst: "Didn't", second: "Rained", notSecond: "Dry"),
			counts: FourBoxCounts(both: 3, firstOnly: 9, secondOnly: 12, neither: 36),
			holdsUp: false,
			explanation: "It rained after a quarter of the washes, and on a quarter of the other days too. The rainy washes are just the ones that stick."
		),
		LuckySocksQuizItem(
			id: 1,
			claim: "Students who use flashcards pass more often.",
			labels: FourBoxLabels(first: "Flashcards", notFirst: "None", second: "Passed", notSecond: "Failed"),
			counts: FourBoxCounts(both: 18, firstOnly: 2, secondOnly: 10, neither: 10),
			holdsUp: true,
			explanation: "Nine in ten flashcard users passed, against half of everyone else. That's a real difference."
		),
		LuckySocksQuizItem(
			id: 2,
			claim: "The hospital is always busier on a full moon.",
			labels: FourBoxLabels(first: "Full moon", notFirst: "Other nights", second: "Busy", notSecond: "Quiet"),
			counts: FourBoxCounts(both: 4, firstOnly: 8, secondOnly: 40, neither: 80),
			holdsUp: false,
			explanation: "A third of full-moon nights were busy, and a third of other nights too. Busy full moons are just easier to remember."
		),
	])

	/// The line under the quiz score when the model on the device can't write one (`LessonScoreLine`)
	static func scoreLine(for score: Int) -> String {
		switch score {
			case 3: "All three. You're already counting the misses."
			case 2: "Two of three. The one you missed is worth another look."
			default: "It's easy to count only the hits. Checking all four boxes is the habit to build."
		}
	}

	/// Socks on, then won, for each game in order
	private static func games(_ pairs: [(Bool, Bool)]) -> [LuckySocksGame] {
		pairs.enumerated().map { index, pair in
			LuckySocksGame(id: index + 1, socks: pair.0, won: pair.1)
		}
	}

	private static func counts(_ boxes: [FourBox]) -> FourBoxCounts {
		FourBoxCounts(
			both: boxes.count { $0 == .both },
			firstOnly: boxes.count { $0 == .firstOnly },
			secondOnly: boxes.count { $0 == .secondOnly },
			neither: boxes.count { $0 == .neither }
		)
	}

	/// The authored answers can't disagree with the data
	private static func checked(_ items: [LuckySocksQuizItem]) -> [LuckySocksQuizItem] {
		for item in items {
			assert(item.holdsUp == item.counts.holdsUp, "\(item.claim) is answered against its own data")
		}
		return items
	}
}
