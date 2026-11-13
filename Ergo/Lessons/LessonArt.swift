//
//  LessonArt.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

extension Lesson {
	/// Its colour on the Learn tab
	var tint: Color {
		switch self {
			case .behindTheWords: .orange
			case .fairPoint: .blue
			case .biggerPicture: .purple
		}
	}
}

/// A small picture of what a lesson looks like, with a tick once it's finished or a lock until it opens
struct LessonArt: View {
	let lesson: Lesson
	let isFinished: Bool
	let isUnlocked: Bool

	var body: some View {
		picture
			.frame(width: 72, height: 72)
			.background(lesson.tint.opacity(0.15), in: .rect(cornerRadius: 20))
			.overlay(alignment: .bottomTrailing) {
				badge
					.offset(x: 6, y: 6)
			}
			.accessibilityHidden(true)
	}

	@ViewBuilder
	private var picture: some View {
		switch lesson {
			case .behindTheWords: ForumArt(tint: lesson.tint)
			case .fairPoint: ChatArt(tint: lesson.tint)
			case .biggerPicture: ChartArt(tint: lesson.tint)
		}
	}

	@ViewBuilder
	private var badge: some View {
		if isFinished {
			Image(systemName: "checkmark.circle.fill")
				.font(.title3)
				.symbolRenderingMode(.palette)
				.foregroundStyle(.white, .green)
		} else if !isUnlocked {
			Image(systemName: "lock.circle.fill")
				.font(.title3)
				.symbolRenderingMode(.palette)
				.foregroundStyle(.white, .gray)
		}
	}
}

/// Lesson 1: lines of a post, with the one that matters lit up
private struct ForumArt: View {
	let tint: Color

	var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			line(width: 30, lit: false)
			line(width: 40, lit: true)
			line(width: 36, lit: false)
			line(width: 22, lit: false)
		}
	}

	private func line(width: CGFloat, lit: Bool) -> some View {
		Capsule()
			.fill(lit ? AnyShapeStyle(tint) : AnyShapeStyle(.secondary.opacity(0.4)))
			.frame(width: width, height: 6)
	}
}

/// Lesson 2: two messages, one each way
private struct ChatArt: View {
	let tint: Color

	var body: some View {
		VStack(spacing: 6) {
			UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 2, bottomTrailingRadius: 8, topTrailingRadius: 8)
				.fill(.secondary.opacity(0.4))
				.frame(width: 32, height: 14)
				.frame(maxWidth: .infinity, alignment: .leading)

			UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 8, bottomTrailingRadius: 2, topTrailingRadius: 8)
				.fill(tint)
				.frame(width: 28, height: 14)
				.frame(maxWidth: .infinity, alignment: .trailing)
		}
		.frame(width: 46)
	}
}

/// Lesson 3: a few ordinary bars and one tall one
private struct ChartArt: View {
	let tint: Color

	var body: some View {
		HStack(alignment: .bottom, spacing: 4) {
			bar(height: 14, lit: false)
			bar(height: 16, lit: false)
			bar(height: 13, lit: false)
			bar(height: 34, lit: true)
			bar(height: 15, lit: true)
		}
		.overlay(alignment: .bottom) {
			Rectangle()
				.fill(.secondary.opacity(0.5))
				.frame(height: 1)
				.offset(y: -15)
		}
	}

	private func bar(height: CGFloat, lit: Bool) -> some View {
		RoundedRectangle(cornerRadius: 2)
			.fill(lit ? AnyShapeStyle(tint) : AnyShapeStyle(.secondary.opacity(0.4)))
			.frame(width: 6, height: height)
	}
}
