//
//  BehindTheWordsLesson.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Saved after every answer, so the lesson reopens where it was left
nonisolated struct BehindTheWordsState: Codable, Hashable, Sendable, Defaults.Serializable {
	nonisolated enum Page: Int, Codable, Hashable, Sendable {
		case behindTheWords
		case deeperLook
		case yourTurn
		case summary
	}

	var page = Page.behindTheWords

	/// Page 1 has turned to the terms
	var showsTerms = false

	/// Question 1: the claim was tapped
	var claimFound = false
	/// Question 1: wrong parts tapped before the claim
	var claimMisses = 0

	/// Question 2: the first pick for each unit, by its number
	var sorted: [Int: BehindTheWordsKind] = [:]
	/// The questions have faded and the passage is down to its skeleton
	var showsSkeleton = false

	/// Page 3: the first pick for each passage, in order. True is "Gives a reason".
	var quizPicks: [Bool] = []

	var allSorted: Bool {
		BehindTheWords.sortable.allSatisfy { sorted[$0.number] != nil }
	}

	var quizScore: Int {
		zip(quizPicks, BehindTheWords.quiz).filter { $0 == $1.givesReason }.count
	}

	var quizFinished: Bool {
		quizPicks.count >= BehindTheWords.quiz.count
	}
}

/// Lesson 1: a forum reply sorted into its claim, reasons and filler
struct BehindTheWordsLesson: View {
	@Default(.behindTheWordsState) private var state

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
			case .behindTheWords:
				BehindTheWordsIntroPage()
			case .deeperLook:
				BehindTheWordsDeeperLookPage()
			case .yourTurn:
				BehindTheWordsYourTurnPage()
			case .summary:
				LessonSummaryPage(
					lesson: .behindTheWords,
					takeaway: "Find what it wants you to believe, then look for what holds it up."
				)
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

/// The full-width button that moves the lesson on
struct BehindTheWordsContinueButton: View {
	let identifier: String
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Text("Continue")
				.font(.headline)
				.frame(maxWidth: .infinity)
		}
		.buttonStyle(.glassProminent)
		.buttonBorderShape(.roundedRectangle(radius: 12))
		.controlSize(.large)
		.accessibilityIdentifier("learn.behindTheWords.continue.\(identifier)")
	}
}
