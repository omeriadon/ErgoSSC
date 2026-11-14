//
//  FairPointIntroPage.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

/// Page 1: the inbox opens Sam's conversation
struct FairPointIntroPage: View {
	@Binding var state: FairPointState

	/// Local, so the open animates whatever the save does
	@State private var isOpen: Bool

	init(state: Binding<FairPointState>) {
		_state = state
		_isOpen = State(initialValue: state.wrappedValue.hasPlayedInbox)
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				screen

				if isOpen {
					// After the conversation has opened, not alongside it
					next
						.transition(.opacity.animation(.smooth(duration: 0.5).delay(0.9)))
				}
			}
			.padding()
		}
		.navigationTitle(lessonTitle(.fairPoint, Lesson.fairPoint.title))
	}

	private var screen: some View {
		ZStack(alignment: .top) {
			if isOpen {
				ChatConversation(thread: FairPoint.sam)
					.transition(openTransition)
			} else {
				ChatInbox(rows: FairPoint.inbox, landingRow: FairPoint.landingRow, onOpen: open)
					.transition(openTransition)
			}
		}
		.clipped()
	}

	/// Like opening a conversation in Messages. SwiftUI turns it into a fade with Reduce Motion.
	private var openTransition: some Transition {
		.push(from: .trailing)
	}

	private var next: some View {
		HStack(alignment: .bottom, spacing: 12) {
			Text("Common scenario: messaging a friend. Arguments can get messy, so let's look at how this one goes")
				.frame(maxWidth: .infinity, alignment: .leading)

			Button {
				state.page = .deeperLook
			} label: {
				Image(systemName: "arrow.right")
					.font(.title3.weight(.semibold))
					.padding(6)
			}
			.buttonStyle(.glassProminent)
			.buttonBorderShape(.circle)
			.accessibilityLabel("Next")
			.accessibilityIdentifier("learn.fairPoint.next")
		}
	}

	private func open() {
		withAnimation(.smooth(duration: 0.55)) {
			isOpen = true
		}
		state.hasPlayedInbox = true
	}
}
