//
//  BehindTheWordsYourTurnPage.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Page 3: four passages, one at a time, each holding something or nothing
struct BehindTheWordsYourTurnPage: View {
	@Default(.behindTheWordsState) private var state

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	/// The passages shown so far: every answered one, and the next
	private var visible: ArraySlice<BehindTheWordsQuizItem> {
		BehindTheWords.quiz.prefix(state.quizPicks.count + 1)
	}

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				content
					.padding()
			}
			.onChange(of: state.quizPicks.count) { _, _ in
				scrollToEnd(proxy)
			}
		}
		.navigationTitle(lessonTitle(.behindTheWords, "Your turn!"))
		.sensoryFeedback(trigger: state.quizPicks) { old, new in
			feedback(old: old, new: new)
		}
	}

	private var content: some View {
		VStack(alignment: .leading, spacing: 20) {
			Text("For each of these, look behind the words. Is there a reason holding it up? ↓")
				.font(.headline)
				.fixedSize(horizontal: false, vertical: true)

			ForEach(visible) { item in
				BehindTheWordsQuizCard(item: item, pick: pick(for: item)) { givesReason in
					answer(item, givesReason: givesReason)
				}
				.id(item.id)
				.transition(.opacity.combined(with: .offset(y: 24)))
			}

			if state.quizFinished {
				BehindTheWordsScore(score: state.quizScore, results: quizResults) {
					state.page = .summary
				}
				.id("score")
				.transition(.opacity)
			}

			// Room to scroll past the end
			Color.clear
				.frame(height: 250)
		}
		.animation(reduceMotion ? .easeInOut(duration: 0.25) : .smooth(duration: 0.6).delay(1.4), value: state.quizPicks.count)
	}

	/// What the line under the score is written from
	private var quizResults: [LessonQuizResult] {
		zip(BehindTheWords.quiz, state.quizPicks).map { item, pick in
			LessonQuizResult(
				question: item.text,
				answer: item.givesReason ? "it gives a reason" : "no reason is given",
				gotRight: pick == item.givesReason
			)
		}
	}

	private func pick(for item: BehindTheWordsQuizItem) -> Bool? {
		state.quizPicks.indices.contains(item.id) ? state.quizPicks[item.id] : nil
	}

	/// Only the first answer counts, so an answered passage is locked
	private func answer(_ item: BehindTheWordsQuizItem, givesReason: Bool) {
		guard state.quizPicks.count == item.id else { return }
		state.quizPicks.append(givesReason)
	}

	private func scrollToEnd(_ proxy: ScrollViewProxy) {
		let finished = state.quizFinished
		let next = state.quizPicks.count
		Task {
			try? await Task.sleep(for: .seconds(1.6))
			withAnimation(reduceMotion ? nil : .smooth(duration: 0.7)) {
				if finished {
					proxy.scrollTo("score", anchor: .bottom)
				} else {
					proxy.scrollTo(next, anchor: .bottom)
				}
			}
		}
	}

	private func feedback(old: [Bool], new: [Bool]) -> SensoryFeedback? {
		guard new.count > old.count, let last = new.last else {
			return nil
		}
		return last == BehindTheWords.quiz[new.count - 1].givesReason ? .success : .warning
	}
}

private struct BehindTheWordsQuizCard: View {
	let item: BehindTheWordsQuizItem
	/// True is "Gives a reason", nil is unanswered
	let pick: Bool?
	let onPick: (Bool) -> Void

	private var isRight: Bool {
		pick == item.givesReason
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			Text(item.text)
				.font(.title3)
				.fontDesign(.serif)
				.fixedSize(horizontal: false, vertical: true)
				.padding(16)
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(.background.secondary, in: .rect(cornerRadius: 18))

			Text("This passage…")
				.font(.subheadline)
				.foregroundStyle(.secondary)

			HStack(spacing: 8) {
				option("Gives a reason", givesReason: true)
				option("No reason given", givesReason: false)
			}

			if pick != nil {
				result
					.transition(.opacity)
			}
		}
		.padding(.vertical, 20)
		.animation(.smooth(duration: 0.3), value: pick)
	}

	private var result: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(isRight ? "That's right." : "Not quite.")
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(isRight ? .green : .orange)

			Text(item.explanation)
				.font(.subheadline)
				.fixedSize(horizontal: false, vertical: true)
		}
		.accessibilityElement(children: .combine)
	}

	private func option(_ title: String, givesReason: Bool) -> some View {
		BehindTheWordsQuizOption(
			title: title,
			isAnswer: givesReason == item.givesReason,
			isPicked: pick == givesReason,
			isLocked: pick != nil
		) {
			onPick(givesReason)
		}
		.accessibilityIdentifier("learn.behindTheWords.quiz.\(item.id).\(givesReason ? "givesReason" : "noReason")")
	}
}

/// One of the two answers. Once picked, the right one is filled in.
private struct BehindTheWordsQuizOption: View {
	let title: String
	let isAnswer: Bool
	let isPicked: Bool
	let isLocked: Bool
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Text(title)
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(textColor)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 11)
				.background(fillColor, in: .rect(cornerRadius: 12))
				.overlay {
					RoundedRectangle(cornerRadius: 12)
						.strokeBorder(isLocked && isPicked && !isAnswer ? Color.orange : .clear, lineWidth: 1.5)
				}
				.contentShape(.rect(cornerRadius: 12))
		}
		.buttonStyle(BehindTheWordsPressStyle())
		.disabled(isLocked)
		.accessibilityValue(isLocked && isPicked ? "Your answer" : "")
	}

	private var fillColor: Color {
		guard isLocked else {
			return .primary.opacity(0.06)
		}
		return isAnswer ? .green : .clear
	}

	private var textColor: Color {
		guard isLocked else {
			return .primary
		}
		return isAnswer ? .white : .secondary
	}
}

/// The score once every passage is answered, and a line about it
private struct BehindTheWordsScore: View {
	let score: Int
	let results: [LessonQuizResult]
	let onContinue: () -> Void

	var body: some View {
		VStack(spacing: 10) {
			Text("\(score) of \(BehindTheWords.quiz.count)")
				.font(.largeTitle.bold().monospacedDigit())

			LessonScoreLine(lesson: .behindTheWords, results: results, fallback: BehindTheWords.scoreLine(for: score))

			BehindTheWordsContinueButton(identifier: "quiz", action: onContinue)
				.padding(.top, 12)
		}
		.frame(maxWidth: .infinity)
		.padding(.top, 12)
	}
}
