//
//  ChatConversation.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

/// A whole conversation, grouped like Messages. Each page decorates the bubbles its own way.
struct ChatConversation<Bubble: View>: View {
	let thread: ChatThread
	@ViewBuilder var bubble: (ChatMessage, ChatBubble) -> Bubble

	var body: some View {
		VStack(spacing: 0) {
			ChatHeader(name: thread.name)
				.padding(.bottom, 14)

			ForEach(thread.messages.indices, id: \.self) { index in
				row(index)
			}
		}
		.padding(12)
		.background(Color(.systemBackground), in: .rect(cornerRadius: 24))
		.overlay {
			RoundedRectangle(cornerRadius: 24)
				.stroke(.quaternary, lineWidth: 1)
		}
	}

	private func row(_ index: Int) -> some View {
		let messages = thread.messages
		let message = messages[index]
		let isYou = message.sender == .you
		let startsRun = index == 0 || messages[index - 1].sender != message.sender
		let endsRun = index == messages.count - 1 || messages[index + 1].sender != message.sender

		return HStack(spacing: 0) {
			if isYou {
				Spacer(minLength: 48)
			}

			bubble(message, ChatBubble(message: message, hasTail: endsRun))

			if !isYou {
				Spacer(minLength: 48)
			}
		}
		.padding(.top, index == 0 ? 0 : startsRun ? 10 : 2)
	}
}

extension ChatConversation where Bubble == ChatBubble {
	init(thread: ChatThread) {
		self.init(thread: thread) { _, bubble in
			bubble
		}
	}
}

/// The contact's picture and name, at the top of a conversation
struct ChatHeader: View {
	let name: String

	var body: some View {
		VStack(spacing: 4) {
			ChatAvatar(name: name, size: 44)

			Text(name)
				.font(.caption)
		}
		.frame(maxWidth: .infinity)
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("Conversation with \(name)")
	}
}

/// A coloured circle with the contact's initial, like a contact with no photo
struct ChatAvatar: View {
	let name: String
	let size: CGFloat
	var colors: [Color] = [.green, .mint]

	var body: some View {
		Text(name.prefix(1))
			.font(.system(size: size * 0.45, weight: .medium, design: .rounded))
			.foregroundStyle(.white)
			.frame(width: size, height: size)
			.background(
				LinearGradient(
					colors: colors,
					startPoint: .top,
					endPoint: .bottom
				),
				in: .circle
			)
	}
}
