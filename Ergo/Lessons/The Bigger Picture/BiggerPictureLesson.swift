//
//  BiggerPictureLesson.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Saved as it happens, so the lesson reopens where it was left
nonisolated struct BiggerPictureState: Codable, Hashable, Sendable, Defaults.Serializable {
	nonisolated enum Page: Int, Codable, Hashable, Sendable {
		case biggerPicture
		case deeperLook
		case yourTurn
		case summary
	}

	var page = Page.biggerPicture

	/// Page 1's chart has zoomed out to every year
	var zoomedOut = false

	/// Page 2: where the counting starts
	var countingFrom = BiggerPicture.firstYear
	/// Page 2: the start year that makes the cameras look best was found
	var foundBest = false

	/// Page 3: the first pick for each headline, in order. True is "Fair picture".
	var quizPicks: [Bool] = []

	var quizFinished: Bool {
		quizPicks.count >= BiggerPicture.quiz.count
	}
}

/// Lesson 3: a headline's number, and what it looks like zoomed out
struct BiggerPictureLesson: View {
	@Default(.biggerPictureState) private var state

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
			case .biggerPicture:
				BiggerPictureIntroPage()
			case .deeperLook:
				BiggerPictureDeeperLookPage()
			case .yourTurn:
				BiggerPictureYourTurnPage()
			case .summary:
				LessonSummaryPage(lesson: .biggerPicture, takeaway: BiggerPicture.takeaway)
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
