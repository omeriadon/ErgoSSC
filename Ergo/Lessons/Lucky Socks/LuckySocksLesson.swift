//
//  LuckySocksLesson.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Saved as it happens, so the lesson reopens where it was left
nonisolated struct LuckySocksState: Codable, Hashable, Sendable, Defaults.Serializable {
	nonisolated enum Page: Int, Codable, Hashable, Sendable {
		case luckySocks
		case deeperLook
		case yourTurn
		case summary
	}

	var page = Page.luckySocks

	/// Page 1 has shown the whole season and sorted it
	var showsSeason = false

	/// Page 2: the boxes counted so far, besides the one Jess remembers
	var countedBoxes: Set<FourBox> = []

	var countedAll: Bool {
		countedBoxes.count == FourBox.allCases.count - 1
	}

	/// Page 3: the first pick for each claim, in order. True is "Holds up".
	var quizPicks: [Bool] = []
	/// Page 3: how far the Next button has gone. One past the last claim shows the score.
	var quizShown = 1

	var quizScore: Int {
		zip(quizPicks, LuckySocks.quiz).filter { $0 == $1.holdsUp }.count
	}
}

/// Lesson 4: a friend's lucky socks, and the four boxes that check them
struct LuckySocksLesson: View {
	@Default(.luckySocksState) private var state

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	var body: some View {
		ZStack {
			page
				.id(state.page)
				.transition(pageTransition)
		}
		.animation(reduceMotion ? .easeInOut(duration: 0.2) : .smooth(duration: 0.45), value: state.page)
	}

	@ViewBuilder
	private var page: some View {
		switch state.page {
			case .luckySocks:
				LuckySocksIntroPage()
			case .deeperLook:
				LuckySocksDeeperLookPage()
			case .yourTurn:
				LuckySocksYourTurnPage()
			case .summary:
				LessonSummaryPage(lesson: .luckySocks, takeaway: LuckySocks.takeaway)
		}
	}

	/// SwiftUI turns this into a fade with Reduce Motion
	private var pageTransition: some Transition {
		AsymmetricTransition(
			insertion: MoveTransition(edge: .trailing).combined(with: .opacity),
			removal: MoveTransition(edge: .leading).combined(with: .opacity)
		)
	}
}
