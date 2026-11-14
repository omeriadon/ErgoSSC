//
//  FairPointDeeperLookPage.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

/// Page 2: tap each of Sam's messages for a popover about it
struct FairPointDeeperLookPage: View {
	@Binding var state: FairPointState

	@State private var shown: String?

	private var remaining: Int {
		FairPoint.sam.notedMessages.filter { !state.tappedSam.contains($0.id) }.count
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				Text("Tap each of Sam's messages to take a deeper look ↓")
					.multilineTextAlignment(.center)
					.frame(maxWidth: .infinity)

				ChatConversation(thread: FairPoint.sam) { message, bubble in
					bubbleView(message, bubble)
				}

				footer
					.frame(maxWidth: .infinity)
			}
			.padding()
		}
		.navigationTitle(lessonTitle(.fairPoint, "Deeper look"))
	}

	@ViewBuilder
	private func bubbleView(_ message: ChatMessage, _ bubble: ChatBubble) -> some View {
		if message.note == nil {
			bubble
		} else {
			SamBubble(
				message: message,
				bubble: bubble,
				isTapped: state.tappedSam.contains(message.id),
				isShowingNote: fairPointNoteBinding(message.id, shown: $shown)
			) {
				state.tappedSam.insert(message.id)
				shown = message.id
			}
		}
	}

	@ViewBuilder
	private var footer: some View {
		if remaining > 0 {
			Text("\(remaining) more to go ↑")
				.foregroundStyle(.secondary)
		} else {
			Button {
				state.page = .yourTurn
			} label: {
				Text("Continue")
					.padding(5)
			}
			.buttonStyle(.glassProminent)
			.buttonBorderShape(.roundedRectangle(radius: 12))
			.accessibilityIdentifier("learn.fairPoint.continue")
		}
	}
}

/// One of Sam's messages, which shows its popover when tapped
private struct SamBubble: View {
	let message: ChatMessage
	let bubble: ChatBubble
	let isTapped: Bool
	@Binding var isShowingNote: Bool
	let onTap: () -> Void

	private var value: String {
		isTapped ? "Looked at" : ""
	}

	var body: some View {
		HStack(spacing: 6) {
			Button(action: onTap) {
				bubble
			}
			.buttonStyle(.plain)
			.fairPointNote(message.note, isPresented: $isShowingNote)
			.accessibilityLabel("Sam: \(message.text)")
			.accessibilityValue(value)
			.accessibilityHint("Shows a deeper look")
			.accessibilityIdentifier("learn.fairPoint.\(message.id)")

			ChatMark(symbol: "checkmark.circle.fill", tint: .secondary, isShown: isTapped)
		}
	}
}
