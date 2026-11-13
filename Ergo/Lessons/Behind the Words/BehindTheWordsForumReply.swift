//
//  BehindTheWordsForumReply.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

/// The lesson's passage as it would really be seen: a reply in a local forum thread
struct BehindTheWordsForumReply<Content: View>: View {
	/// The reply's text, or its parts once it's split
	@ViewBuilder var content: Content

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			ForumThreadHeader()

			Divider()

			VStack(alignment: .leading, spacing: 12) {
				ForumReplyAuthor()

				content

				ForumReplyFooter()
			}
			.padding(16)
		}
		.background(.background.secondary, in: .rect(cornerRadius: 22))
		.overlay {
			RoundedRectangle(cornerRadius: 22)
				.strokeBorder(.separator, lineWidth: 0.5)
		}
	}
}

/// The forum, the thread's title and how busy it is
private struct ForumThreadHeader: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Label("Northside Locals · Food & Drink", systemImage: "bubble.left.and.bubble.right.fill")
				.font(.caption.weight(.semibold))
				.foregroundStyle(.secondary)

			Text(BehindTheWords.threadTitle)
				.font(.title3.bold())

			HStack(spacing: 12) {
				Label("18 replies", systemImage: "arrowshape.turn.up.left.2")
				Label("312 views", systemImage: "eye")
			}
			.font(.caption)
			.foregroundStyle(.secondary)
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.accessibilityElement(children: .combine)
		.accessibilityAddTraits(.isHeader)
	}
}

/// Who wrote the reply, and when
private struct ForumReplyAuthor: View {
	var body: some View {
		HStack(spacing: 10) {
			Text("J")
				.font(.headline)
				.foregroundStyle(.white)
				.frame(width: 38, height: 38)
				.background(
					LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
					in: .circle
				)

			VStack(alignment: .leading, spacing: 1) {
				HStack(spacing: 4) {
					Text("jess_on_platform2")
						.font(.subheadline.weight(.semibold))
					Image(systemName: "checkmark.seal.fill")
						.font(.caption)
						.foregroundStyle(.tint)
				}

				Text("Local regular · 2h ago")
					.font(.caption)
					.foregroundStyle(.secondary)
			}

			Spacer(minLength: 0)

			Image(systemName: "ellipsis")
				.foregroundStyle(.secondary)
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("Reply from jess_on_platform2, a local regular, 2 hours ago")
	}
}

/// Likes, and the actions under a post. Only for show.
private struct ForumReplyFooter: View {
	var body: some View {
		HStack(spacing: 18) {
			Label("24", systemImage: "heart.fill")
				.foregroundStyle(.pink)
			Label("Reply", systemImage: "arrowshape.turn.up.left")
			Label("Share", systemImage: "square.and.arrow.up")
			Spacer(minLength: 0)
		}
		.font(.caption.weight(.medium))
		.foregroundStyle(.secondary)
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("24 likes")
	}
}
