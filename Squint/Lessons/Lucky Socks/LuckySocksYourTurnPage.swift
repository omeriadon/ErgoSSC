//
//  LuckySocksYourTurnPage.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Page 3: three claims, each with its four boxes counted. Does each hold up?
struct LuckySocksYourTurnPage: View {
	@Default(.luckySocksState) private var state

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	private var visible: [LuckySocksQuizItem] {
		Array(LuckySocks.quiz.prefix(state.quizShown))
	}

	private var showsScore: Bool {
		state.quizShown > LuckySocks.quiz.count
	}

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				content
					.padding()
			}
			.onChange(of: state.quizShown) { old, new in
				guard new > old else { return }
				scrollToEnd(proxy)
			}
		}
		.navigationTitle(lessonTitle(.luckySocks, "Your turn!"))
		.sensoryFeedback(trigger: state.quizPicks) { old, new in
			feedback(old: old, new: new)
		}
	}

	private var content: some View {
		VStack(alignment: .leading, spacing: 28) {
			Text("Here are some more. Does each one hold up? ↓")
				.font(.headline)
				.fixedSize(horizontal: false, vertical: true)

			ForEach(visible) { item in
				LuckySocksQuizCard(item: item, pick: pick(for: item), onNext: onNext(for: item)) { holdsUp in
					answer(item, holdsUp: holdsUp)
				}
				.id(item.id)
				.transition(.opacity.combined(with: .offset(y: 24)))
			}

			if showsScore {
				LuckySocksScore(score: state.quizScore, results: quizResults) {
					state.page = .summary
				}
				.id("continue")
				.transition(.opacity)
			}

			// Room to scroll past the end
			Color.clear
				.frame(height: 250)
		}
		.animation(reduceMotion ? .easeInOut(duration: 0.25) : .smooth(duration: 0.6), value: state.quizShown)
	}

	/// Only the last claim on screen moves on, once it's answered
	private func onNext(for item: LuckySocksQuizItem) -> (() -> Void)? {
		guard item.id == state.quizShown - 1, pick(for: item) != nil else { return nil }
		return {
			state.quizShown += 1
		}
	}

	/// What the line under the score is written from
	private var quizResults: [LessonQuizResult] {
		zip(LuckySocks.quiz, state.quizPicks).map { item, pick in
			LessonQuizResult(
				question: item.claim,
				answer: item.holdsUp ? "it holds up" : "it doesn't hold up",
				gotRight: pick == item.holdsUp
			)
		}
	}

	private func pick(for item: LuckySocksQuizItem) -> Bool? {
		state.quizPicks.indices.contains(item.id) ? state.quizPicks[item.id] : nil
	}

	/// Only the first answer counts, so an answered claim is locked
	private func answer(_ item: LuckySocksQuizItem, holdsUp: Bool) {
		guard state.quizPicks.count == item.id else { return }
		state.quizPicks.append(holdsUp)
	}

	private func scrollToEnd(_ proxy: ScrollViewProxy) {
		let finished = showsScore
		let next = state.quizShown - 1
		Task {
			// After the new claim has started to fade in
			try? await Task.sleep(for: .seconds(0.3))
			withAnimation(reduceMotion ? nil : .smooth(duration: 0.7)) {
				if finished {
					proxy.scrollTo("continue", anchor: .center)
				} else {
					proxy.scrollTo(next, anchor: .top)
				}
			}
		}
	}

	private func feedback(old: [Bool], new: [Bool]) -> SensoryFeedback? {
		guard new.count > old.count, let last = new.last else {
			return nil
		}
		return last == LuckySocks.quiz[new.count - 1].holdsUp ? .success : .warning
	}
}

private struct LuckySocksQuizCard: View {
	let item: LuckySocksQuizItem
	/// True is "Holds up", nil is unanswered
	let pick: Bool?
	/// Shown once the explanation is, on the claim that's last on screen
	let onNext: (() -> Void)?
	let onPick: (Bool) -> Void

	/// Local, so the reveal can play after the pick
	@State private var showsReveal: Bool
	@State private var showsExplanation: Bool
	@State private var showsNext: Bool

	init(item: LuckySocksQuizItem, pick: Bool?, onNext: (() -> Void)?, onPick: @escaping (Bool) -> Void) {
		self.item = item
		self.pick = pick
		self.onNext = onNext
		self.onPick = onPick
		_showsReveal = State(initialValue: pick != nil)
		_showsExplanation = State(initialValue: pick != nil)
		_showsNext = State(initialValue: pick != nil)
	}

	private var isRight: Bool {
		pick == item.holdsUp
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			claim

			Text("This claim…")
				.font(.subheadline)
				.foregroundStyle(.secondary)

			HStack(spacing: 8) {
				option("Holds up", holdsUp: true)
				option("Doesn't hold up", holdsUp: false)
			}

			if showsExplanation {
				result
					.transition(.opacity)

				// Local, so it comes in after the explanation, but goes at once when tapped
				if let onNext, showsNext {
					nextButton(onNext)
						.transition(.opacity)
				}
			}
		}
		.onChange(of: pick) { old, new in
			guard old == nil, new != nil else { return }
			Task {
				await reveal()
			}
		}
	}

	private var claim: some View {
		VStack(alignment: .leading, spacing: 14) {
			Text(item.claim)
				.font(.title3.bold())
				.fixedSize(horizontal: false, vertical: true)

			FourBoxGrid(labels: item.labels) { box in
				Text("\(item.counts[box])")
					.font(.title3.bold().monospacedDigit())
					.frame(maxWidth: .infinity, minHeight: 52)
					.background {
						// Before the answer, only the box people notice is lit
						FourBoxBackground(isLit: showsReveal || box == .both)
					}
					.opacity(showsReveal || box == .both ? 1 : 0.6)
			}

			if showsReveal {
				FourBoxComparison(labels: item.labels, counts: item.counts)
					.transition(.opacity)
			}
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(.background.secondary, in: .rect(cornerRadius: 18))
		.accessibilityElement(children: .combine)
	}

	private var result: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(resultTitle)
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(isRight ? .green : .orange)

			Text(item.explanation)
				.font(.subheadline)
				.fixedSize(horizontal: false, vertical: true)
		}
		.accessibilityElement(children: .combine)
	}

	private var resultTitle: String {
		if isRight {
			return item.holdsUp ? "That's right, it holds up." : "That's right, it doesn't hold up."
		}
		return item.holdsUp ? "It actually holds up." : "Count the misses, and it doesn't."
	}

	private func nextButton(_ action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Text(item.id == LuckySocks.quiz.count - 1 ? "See how you did" : "Next claim")
				.font(.subheadline.weight(.semibold))
				.frame(maxWidth: .infinity)
				.padding(.vertical, 11)
		}
		.buttonStyle(.glassProminent)
		.buttonBorderShape(.roundedRectangle(radius: 12))
		.padding(.top, 4)
		.accessibilityIdentifier("learn.luckySocks.quiz.\(item.id).next")
	}

	private func option(_ title: String, holdsUp: Bool) -> some View {
		LuckySocksQuizOption(
			title: title,
			isAnswer: holdsUp == item.holdsUp,
			isPicked: pick == holdsUp,
			isLocked: pick != nil
		) {
			onPick(holdsUp)
		}
		.accessibilityIdentifier("learn.luckySocks.quiz.\(item.id).\(holdsUp ? "holdsUp" : "doesNot")")
	}

	/// Every box lights up and the rates come in, then the explanation
	private func reveal() async {
		try? await Task.sleep(for: .seconds(0.4))
		withAnimation(.smooth(duration: 0.5)) {
			showsReveal = true
		}

		try? await Task.sleep(for: .seconds(1))
		withAnimation(.smooth(duration: 0.4)) {
			showsExplanation = true
		}

		try? await Task.sleep(for: .seconds(0.6))
		withAnimation(.smooth(duration: 0.4)) {
			showsNext = true
		}
	}
}

/// One of the two answers. Once picked, the right one is filled in.
private struct LuckySocksQuizOption: View {
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
		.buttonStyle(.plain)
		.disabled(isLocked)
		.animation(.smooth(duration: 0.3), value: isLocked)
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

/// The score once every claim is answered, and a line about it
private struct LuckySocksScore: View {
	let score: Int
	let results: [LessonQuizResult]
	let onContinue: () -> Void

	var body: some View {
		VStack(spacing: 10) {
			Text("\(score) of \(LuckySocks.quiz.count)")
				.font(.largeTitle.bold().monospacedDigit())

			LessonScoreLine(lesson: .luckySocks, results: results, fallback: LuckySocks.scoreLine(for: score))

			LuckySocksContinueButton(identifier: "quiz", action: onContinue)
				.padding(.top, 12)
		}
		.frame(maxWidth: .infinity)
		.padding(.top, 12)
	}
}
