//
//  FairPointLesson.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// The pages of lesson 2, in order
nonisolated enum FairPointPage: Int, Codable, Hashable, Sendable {
	case intro
	case deeperLook
	case yourTurn
	case summary
}

/// Saved after every tap, so the lesson reopens where it was left
nonisolated struct FairPointState: Codable, Hashable, Sendable, Defaults.Serializable {
	var page = FairPointPage.intro
	/// The inbox on page 1 plays once
	var hasPlayedInbox = false
	/// Sam's messages looked at on page 2
	var tappedSam: Set<String> = []
	/// Leo's messages scribbled over on page 3, fair or not
	var scribbledLeo: Set<String> = []
}

/// Lesson 2: three ways an everyday argument goes wrong, in a messaging app
struct FairPointLesson: View {
	@Default(.fairPointState) private var state

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
			case .intro:
				FairPointIntroPage(state: $state)
			case .deeperLook:
				FairPointDeeperLookPage(state: $state)
			case .yourTurn:
				FairPointYourTurnPage(state: $state)
			case .summary:
				LessonSummaryPage(lesson: .fairPoint, takeaway: FairPoint.takeaway)
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
