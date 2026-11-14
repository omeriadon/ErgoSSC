//
//  LearnTabView.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// The Learn tab: every lesson, all open, in the order they're best done
struct LearnTabView: View {
	@Environment(NavigationManager.self)
	private var navigation

	@Default(.lessonsFinished) private var finished

	private var finishedAll: Bool {
		Lesson.allCases.allSatisfy(finished.contains)
	}

	/// Set when the last lesson is finished, so coming back to the list scrolls down to the note under it
	@State private var revealsNote = false

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				VStack(spacing: 16) {
					ForEach(Lesson.allCases) { lesson in
						card(lesson)
					}

					if finishedAll {
						FinishedAllNote()
							.padding(.vertical, 30)
							.id("finishedAll")
					}
				}
				.padding()
			}
			.onChange(of: finishedAll) { _, all in
				revealsNote = all
			}
			.onAppear {
				guard revealsNote else { return }
				revealsNote = false
				Task {
					// Once the lesson has gone back off the stack
					try? await Task.sleep(for: .seconds(0.5))
					withAnimation(.smooth(duration: 0.8)) {
						proxy.scrollTo("finishedAll", anchor: .bottom)
					}
				}
			}
		}
		.background {
			LearnBackground()
				.ignoresSafeArea()
		}
		.toolbarTitleVire("Learn", "", prominent: true)
		#if DEBUG
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Show Welcome", systemImage: "hand.wave") {
						navigation.presentSheet(.welcome)
					}
				}

				ToolbarItem(placement: .topBarTrailing) {
					Button("Reset All Lessons", systemImage: "arrow.counterclockwise") {
						Lesson.resetAll()
					}
				}
			}
		#endif
	}

	private func card(_ lesson: Lesson) -> some View {
		Button {
			navigation.learnPath = [.lesson(lesson)]
		} label: {
			LessonCard(lesson: lesson, isFinished: finished.contains(lesson))
		}
		.buttonStyle(.plain)
		.contextMenu {
			Button("Start Over", systemImage: "arrow.counterclockwise") {
				lesson.startOver()
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

/// One lesson in its colour: its picture, title and question, and what it teaches
private struct LessonCard: View {
	let lesson: Lesson
	let isFinished: Bool

	var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			HStack(alignment: .top, spacing: 14) {
				LessonArt(lesson: lesson, isFinished: isFinished)

				VStack(alignment: .leading, spacing: 8) {
					Text(lesson.title)
						.font(.title3.bold())

					Text(lesson.question)
						.font(.subheadline)
						.foregroundStyle(.white.opacity(0.85))
						.fixedSize(horizontal: false, vertical: true)

					LessonTopics(topics: lesson.topics)
						.padding(.top, 10)
				}

				Spacer(minLength: 0)
			}
		}
		// A button's label centres wrapped lines by default
		.multilineTextAlignment(.leading)
		.foregroundStyle(.white)
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background {
			// Behind the content rather than on it, so the glass doesn't wash out the art's colours
			Color.clear
				.glassEffect(.clear.tint(lesson.tint).interactive(), in: .rect(cornerRadius: 34))
		}
		.contentShape(.rect(cornerRadius: 34))
		.accessibilityElement(children: .combine)
		.accessibilityValue(isFinished ? "Finished" : "")
	}
}

/// What a lesson teaches
private struct LessonTopics: View {
	let topics: [String]

	var body: some View {
		Text(topics.joined(separator: ", "))
			.font(.caption.weight(.semibold))
			.foregroundStyle(.white.opacity(0.85))
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

			Text("Next time you read a post, an ad or an argument, you'll be able to see what it's actually claiming, and whether it holds it up. There's more to explore in the [Library](squint://library), too.")
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
		.padding(.bottom, 35)
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
