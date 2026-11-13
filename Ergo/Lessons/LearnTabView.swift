//
//  LearnTabView.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// The Learn tab: every lesson, in order, each opening once the one before is finished
struct LearnTabView: View {
	@Environment(NavigationManager.self)
	private var navigation

	@Default(.lessonsFinished) private var finished

	private var finishedAll: Bool {
		Lesson.allCases.allSatisfy(finished.contains)
	}

	var body: some View {
		ScrollView {
			VStack(spacing: 16) {
				ForEach(Lesson.allCases) { lesson in
					card(lesson)
				}

				if finishedAll {
					FinishedAllNote()
						.padding(.top, 30)
				}
			}
			.padding()
		}
		.background {
			LearnBackground()
				.ignoresSafeArea()
		}
		.toolbarTitleVire("Learn", "")
		#if DEBUG
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Reset All Lessons", systemImage: "arrow.counterclockwise") {
						Lesson.resetAll()
					}
				}
			}
		#endif
	}

	private func card(_ lesson: Lesson) -> some View {
		let isUnlocked = lesson.isUnlocked(finished: finished)

		return Button {
			navigation.learnPath = [.lesson(lesson)]
		} label: {
			LessonCard(lesson: lesson, isFinished: finished.contains(lesson), isUnlocked: isUnlocked)
		}
		.buttonStyle(.plain)
		.disabled(!isUnlocked)
		.contextMenu {
			if isUnlocked {
				Button("Start Over", systemImage: "arrow.counterclockwise") {
					lesson.startOver()
				}
			}

			#if DEBUG
				Button("Reset Lesson", systemImage: "trash", role: .destructive) {
					lesson.startOver()
					finished.remove(lesson)
				}
			#endif
		}
		.accessibilityIdentifier("learn.lesson.\(lesson.rawValue)")
	}
}

/// One lesson: its picture, title and question, and what it teaches
private struct LessonCard: View {
	let lesson: Lesson
	let isFinished: Bool
	let isUnlocked: Bool

	var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			HStack(alignment: .top, spacing: 14) {
				LessonArt(lesson: lesson, isFinished: isFinished, isUnlocked: isUnlocked)

				VStack(alignment: .leading, spacing: 8) {
					Text(lesson.title)
						.font(.title3.bold())

					Text(isUnlocked ? lesson.question : "Finish lesson \(lesson.number - 1) first")
						.font(.subheadline)
						.foregroundStyle(.secondary)
						.fixedSize(horizontal: false, vertical: true)

					LessonTopics(topics: lesson.topics, tint: lesson.tint)
				}

				Spacer(minLength: 0)
			}
		}
		// A button's label centres wrapped lines by default
		.multilineTextAlignment(.leading)
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 28))
		.opacity(isUnlocked ? 1 : 0.55)
		.contentShape(.rect(cornerRadius: 28))
		.accessibilityElement(children: .combine)
		.accessibilityValue(isFinished ? "Finished" : isUnlocked ? "" : "Locked")
	}
}

/// What a lesson teaches, as small tags that wrap
private struct LessonTopics: View {
	let topics: [String]
	let tint: Color

	var body: some View {
		Text(topics.joined(separator: ", "))
			.font(.caption.weight(.medium))
			.foregroundStyle(tint)
	}
}

/// Under the lessons once every one is finished
private struct FinishedAllNote: View {
	@Environment(NavigationManager.self)
	private var navigation

	var body: some View {
		VStack(spacing: 6) {
			Text("Well done, you've finished every lesson!")
				.font(.headline)

			Text("Next time you read a post, an ad or an argument, you'll be able to see what it's actually claiming, and whether it holds it up. There's more to explore in the [Library](ergo://library), too.")
				.font(.subheadline)
				.foregroundStyle(.secondary)
				.tint(.blue)
				.environment(\.openURL, OpenURLAction { _ in
					navigation.reveal(.library)
					return .handled
				})
		}
		.multilineTextAlignment(.center)
		.frame(maxWidth: .infinity)
		.padding(.top, 12)
	}
}

/// A faint dither behind the list
private struct LearnBackground: View {
	@Environment(\.colorScheme) private var colorScheme

	var body: some View {
		DitherView(configuration: configuration)
	}

	private var configuration: DitherConfiguration {
		var configuration = detailViewConf
		let dot: SIMD3<Float> = colorScheme == .dark ? SIMD3(1, 1, 1) : SIMD3(0, 0, 0)
		configuration.palette = [dot, dot]
		configuration.transparent = true
		configuration.opacity = colorScheme == .dark ? 0.48 : 0.08
		return configuration
	}
}

/// Lays its views out in rows, starting a new row when one is full
private struct FlowLayout: Layout {
	var spacing: CGFloat

	func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
		let rows = rows(for: subviews, width: proposal.width ?? .infinity)
		let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(0, rows.count - 1))
		let width = rows.map(\.width).max() ?? 0
		return CGSize(width: proposal.width ?? width, height: height)
	}

	func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
		var y = bounds.minY
		for row in rows(for: subviews, width: bounds.width) {
			var x = bounds.minX
			for index in row.indices {
				let size = subviews[index].sizeThatFits(.unspecified)
				subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
				x += size.width + spacing
			}
			y += row.height + spacing
		}
	}

	private struct Row {
		var indices: [Int] = []
		var width: CGFloat = 0
		var height: CGFloat = 0
	}

	private func rows(for subviews: Subviews, width: CGFloat) -> [Row] {
		var rows: [Row] = [Row()]
		for index in subviews.indices {
			let size = subviews[index].sizeThatFits(.unspecified)
			let added = rows[rows.count - 1].indices.isEmpty ? size.width : rows[rows.count - 1].width + spacing + size.width
			if added > width, !rows[rows.count - 1].indices.isEmpty {
				rows.append(Row())
			}
			var row = rows[rows.count - 1]
			row.width = row.indices.isEmpty ? size.width : row.width + spacing + size.width
			row.height = max(row.height, size.height)
			row.indices.append(index)
			rows[rows.count - 1] = row
		}
		return rows
	}
}
