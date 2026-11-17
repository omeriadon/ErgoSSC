//
//  BehindTheWordsPost.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

/// The lesson's passage as it would really be seen: a post in a social feed
struct BehindTheWordsPost<Content: View>: View {
	/// The post's text, or its parts once it's split
	@ViewBuilder var content: Content

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			PostAuthor()

			content

			PostFooter()
		}
		.padding(16)
		.background(.background.secondary, in: .rect(cornerRadius: 22))
		.overlay {
			RoundedRectangle(cornerRadius: 22)
				.strokeBorder(.separator, lineWidth: 0.5)
		}
	}
}

/// Who wrote the post, and when
private struct PostAuthor: View {
	var body: some View {
		HStack(spacing: 10) {
			Text("M")
				.font(.headline)
				.foregroundStyle(.white)
				.frame(width: 38, height: 38)
				.background(
					LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
					in: .circle
				)

			VStack(alignment: .leading, spacing: 1) {
				Text("Maya")
					.font(.subheadline.weight(.semibold))

				Text("@maya.k · 2h")
					.font(.caption)
					.foregroundStyle(.secondary)
			}

			Spacer(minLength: 0)

			Image(systemName: "ellipsis")
				.foregroundStyle(.secondary)
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("Post from Maya, 2 hours ago")
	}
}

/// Likes, replies and reposts under a post. Only for show.
private struct PostFooter: View {
	var body: some View {
		HStack(spacing: 18) {
			Label("1.2K", systemImage: "heart.fill")
				.foregroundStyle(.pink)
			Label("86", systemImage: "bubble.right")
			Label("340", systemImage: "arrow.2.squarepath")
			Image(systemName: "square.and.arrow.up")
			Spacer(minLength: 0)
		}
		.font(.caption.weight(.medium))
		.foregroundStyle(.secondary)
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("1.2K likes, 86 replies, 340 reposts")
	}
}
