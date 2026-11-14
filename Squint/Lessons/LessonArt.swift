//
//  LessonArt.swift
//  Squint
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
			case .luckySocks: .green
		}
	}
}

/// A small picture of what a lesson looks like, white on its solid colour, with a checkmark once it's finished
struct LessonArt: View {
	let lesson: Lesson
	let isFinished: Bool

	var body: some View {
		picture
			.foregroundStyle(.white)
			.frame(width: 72, height: 72)
			.background(lesson.tint, in: .rect(cornerRadius: 20))
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
			case .luckySocks: LessonSymbol(name: "square.grid.2x2", tint: lesson.tint)
		}
	}

	@ViewBuilder
	private var badge: some View {
		if isFinished {
			Image(systemName: "checkmark")
				.font(.caption.weight(.heavy))
				.foregroundStyle(lesson.tint)
				.frame(width: 24, height: 24)
				.background(.white, in: .circle)
				.shadow(color: .black.opacity(0.2), radius: 2, y: 1)
		}
	}
}

/// Lesson 1: reading closely
private struct ForumArt: View {
	let tint: Color

	var body: some View {
		LessonSymbol(name: "rectangle.and.text.magnifyingglass", tint: tint)
	}
}

/// Lesson 2: a conversation
private struct ChatArt: View {
	let tint: Color

	var body: some View {
		LessonSymbol(name: "ellipsis.message", tint: tint)
	}
}

/// Lesson 3: a chart
private struct ChartArt: View {
	let tint: Color

	var body: some View {
		LessonSymbol(name: "chart.bar.xaxis", tint: tint)
	}
}

/// Fitted to the same box, so every lesson's symbol is the same size whatever its shape
private struct LessonSymbol: View {
	let name: String
	let tint: Color

	var body: some View {
		Image(systemName: name)
			.resizable()
			.scaledToFit()
			.fontWeight(.medium)
			.frame(width: 46, height: 46)
	}
}
