//
//  LearnTabView.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// The Learn tab: every lesson, in order
struct LearnTabView: View {
	@Environment(NavigationManager.self)
	private var navigation

	@Default(.lessonsFinished) private var finished

	var body: some View {
		List(Lesson.allCases) { lesson in
			Button {
				navigation.learnPath = [.lesson(lesson)]
			} label: {
				LessonRow(lesson: lesson, isFinished: finished.contains(lesson))
			}
			.buttonStyle(.plain)
			.contextMenu {
				Button("Start Over", systemImage: "arrow.counterclockwise") {
					lesson.startOver()
				}
			}
			.accessibilityIdentifier("learn.lesson.\(lesson.rawValue)")
		}
		.toolbarTitleVire("Learn", "text.magnifyingglass")
	}
}

private struct LessonRow: View {
	let lesson: Lesson
	let isFinished: Bool

	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: isFinished ? "checkmark.circle.fill" : "\(lesson.number).circle")
				.font(.title2)
				.foregroundStyle(isFinished ? .green : .secondary)
				.accessibilityLabel(isFinished ? "Finished" : "Lesson \(lesson.number)")

			VStack(alignment: .leading, spacing: 2) {
				Text(lesson.title)
					.font(.headline)
				Text(lesson.question)
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}

			Spacer(minLength: 0)

			Image(systemName: "chevron.right")
				.foregroundStyle(.secondary)
		}
		.contentShape(Rectangle())
	}
}
