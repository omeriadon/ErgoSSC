//
//  BiggerPictureYourTurnPage.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Page 3: three headlines, each fair or cherry-picked, and each chart zooms out once answered
struct BiggerPictureYourTurnPage: View {
	@Default(.biggerPictureState) private var state

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	private var visible: [BiggerPictureQuizItem] {
		Array(BiggerPicture.quiz.prefix(state.quizShown))
	}

	private var showsScore: Bool {
		state.quizShown > BiggerPicture.quiz.count
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
		.navigationTitle(lessonTitle(.biggerPicture, "Your turn!"))
		.sensoryFeedback(trigger: state.quizPicks) { old, new in
			feedback(old: old, new: new)
		}
	}

	private var content: some View {
		VStack(alignment: .leading, spacing: 28) {
			Text("Here are some more headlines. Is each one a fair picture, or cherry-picked? ↓")
				.font(.headline)
				.fixedSize(horizontal: false, vertical: true)

			ForEach(visible) { item in
				BiggerPictureQuizCard(item: item, pick: pick(for: item), onNext: onNext(for: item)) { isFair in
					answer(item, isFair: isFair)
				}
				.id(item.id)
				.padding(.bottom, 25)
				.transition(.opacity.combined(with: .offset(y: 24)))
			}

			if showsScore {
				BiggerPictureScore(score: state.quizScore, results: quizResults) {
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

	/// Only the last headline on screen moves on, once it's answered
	private func onNext(for item: BiggerPictureQuizItem) -> (() -> Void)? {
		guard item.id == state.quizShown - 1, pick(for: item) != nil else { return nil }
		return {
			state.quizShown += 1
		}
	}

	/// What the line under the score is written from
	private var quizResults: [LessonQuizResult] {
		zip(BiggerPicture.quiz, state.quizPicks).map { item, pick in
			LessonQuizResult(
				question: item.headline,
				answer: item.isFair ? "a fair picture" : "cherry-picked",
				gotRight: pick == item.isFair
			)
		}
	}

	private func pick(for item: BiggerPictureQuizItem) -> Bool? {
		state.quizPicks.indices.contains(item.id) ? state.quizPicks[item.id] : nil
	}

	/// Only the first answer counts, so an answered headline is locked
	private func answer(_ item: BiggerPictureQuizItem, isFair: Bool) {
		guard state.quizPicks.count == item.id else { return }
		state.quizPicks.append(isFair)
	}

	private func scrollToEnd(_ proxy: ScrollViewProxy) {
		let finished = showsScore
		let next = state.quizShown - 1
		Task {
			// After the new headline has started to fade in
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
		return last == BiggerPicture.quiz[new.count - 1].isFair ? .success : .warning
	}
}

private struct BiggerPictureQuizCard: View {
	let item: BiggerPictureQuizItem
	/// True is "Fair picture", nil is unanswered
	let pick: Bool?
	/// Shown once the explanation is, on the headline that's last on screen
	let onNext: (() -> Void)?
	let onPick: (Bool) -> Void

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	/// Local, so the zoom can play after the pick
	@State private var visibleFrom: Int
	/// Behind `visibleFrom`, so each bar grows in after its year makes room for it
	@State private var grownFrom: Int
	/// Zoomed out, a cherry-picked chart shows the usual line and what was special about its start
	@State private var showsReveal: Bool
	@State private var showsExplanation: Bool
	@State private var showsNext: Bool

	init(item: BiggerPictureQuizItem, pick: Bool?, onNext: (() -> Void)?, onPick: @escaping (Bool) -> Void) {
		self.item = item
		self.pick = pick
		self.onNext = onNext
		self.onPick = onPick
		_visibleFrom = State(initialValue: pick == nil ? item.shownFrom : BiggerPicture.firstYear)
		_grownFrom = State(initialValue: pick == nil ? item.shownFrom : BiggerPicture.firstYear)
		_showsReveal = State(initialValue: pick != nil && !item.isFair)
		_showsExplanation = State(initialValue: pick != nil)
		_showsNext = State(initialValue: pick != nil)
	}

	private var isRight: Bool {
		pick == item.isFair
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			headline

			Text("This headline is…")
				.font(.subheadline)
				.foregroundStyle(.secondary)

			HStack(spacing: 8) {
				option("Fair picture", isFair: true)
				option("Cherry-picked", isFair: false)
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
				await zoomOut()
			}
		}
	}

	private var headline: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(item.headline)
				.font(.system(.title3, design: .serif, weight: .bold))
				.fixedSize(horizontal: false, vertical: true)

			BiggerPictureChart(
				points: item.points,
				measure: item.measure,
				visibleFrom: visibleFrom,
				highlighted: highlighted,
				usual: showsReveal ? item.usual : nil,
				note: showsReveal ? item.pickNote.map { (year: item.pickedFrom, text: $0) } : nil,
				marker: item.marker,
				grownFrom: grownFrom,
				height: 150
			)

			HStack {
				Text(item.measure)
					.font(.caption)
					.foregroundStyle(.secondary)

				Spacer(minLength: 8)

				// Under the chart rather than over it, and only on a chart that zoomed out: one that showed every year all along has nothing to say here
				if item.shownFrom != BiggerPicture.firstYear {
					Label("Zoomed out", systemImage: "arrow.up.left.and.arrow.down.right")
						.font(.caption.weight(.semibold))
						.foregroundStyle(.white)
						.padding(.horizontal, 10)
						.padding(.vertical, 5)
						.background(.orange, in: .rect(cornerRadius: 8))
						.opacity(showsReveal ? 1 : 0)
						.scaleEffect(showsReveal ? 1 : 0.8)
				}
			}
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(.background.secondary, in: .rect(cornerRadius: 18))
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(item.headline)
		.accessibilityValue(chartDescription)
	}

	/// Before the reveal, every bar is lit. After it, only the headline's window is.
	private var highlighted: Set<Int> {
		let from = showsReveal ? item.pickedFrom : BiggerPicture.firstYear
		return Set(item.points.map(\.year).filter { $0 >= from })
	}

	private var chartDescription: String {
		item.points
			.filter { $0.year >= visibleFrom }
			.map { "\($0.year): \(Int($0.value))" }
			.joined(separator: ", ")
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
			return item.isFair ? "That's right, it's fair." : "That's right, it's cherry-picked."
		}
		return item.isFair ? "It's actually fair." : "Zoomed out, it's a different story."
	}

	private func nextButton(_ action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Text(item.id == BiggerPicture.quiz.count - 1 ? "See how you did" : "Next headline")
				.font(.subheadline.weight(.semibold))
				.frame(maxWidth: .infinity)
				.padding(.vertical, 11)
		}
		.buttonStyle(.glassProminent)
		.buttonBorderShape(.roundedRectangle(radius: 12))
		.padding(.top, 4)
		.accessibilityIdentifier("learn.biggerPicture.quiz.\(item.id).next")
	}

	private func option(_ title: String, isFair: Bool) -> some View {
		BiggerPictureQuizOption(
			title: title,
			isAnswer: isFair == item.isFair,
			isPicked: pick == isFair,
			isLocked: pick != nil
		) {
			onPick(isFair)
		}
		.accessibilityIdentifier("learn.biggerPicture.quiz.\(item.id).\(isFair ? "fair" : "cherryPicked")")
	}

	/// The earlier years come in one at a time, then the explanation
	private func zoomOut() async {
		if reduceMotion || visibleFrom == BiggerPicture.firstYear {
			try? await Task.sleep(for: .seconds(0.4))
			withAnimation(.easeInOut(duration: 0.4)) {
				visibleFrom = BiggerPicture.firstYear
				grownFrom = BiggerPicture.firstYear
				showsReveal = !item.isFair
				showsExplanation = true
			}
			try? await Task.sleep(for: .seconds(0.6))
			withAnimation(.smooth(duration: 0.4)) {
				showsNext = true
			}
			return
		}

		try? await Task.sleep(for: .seconds(0.5))
		for year in stride(from: visibleFrom - 1, through: BiggerPicture.firstYear, by: -1) {
			withAnimation(.smooth(duration: 0.4)) {
				visibleFrom = year
			}
			try? await Task.sleep(for: .seconds(0.08))
			withAnimation(.smooth(duration: 0.4)) {
				grownFrom = year
			}
			try? await Task.sleep(for: .seconds(0.1))
		}

		// What zooming out shows: the usual line, then what was special about the headline's start
		try? await Task.sleep(for: .seconds(0.5))
		withAnimation(.bouncy(duration: 0.5)) {
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
private struct BiggerPictureQuizOption: View {
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

/// The score once every headline is answered, and a line about it
private struct BiggerPictureScore: View {
	let score: Int
	let results: [LessonQuizResult]
	let onContinue: () -> Void

	var body: some View {
		VStack(spacing: 10) {
			Text("\(score) of \(BiggerPicture.quiz.count)")
				.font(.largeTitle.bold().monospacedDigit())

			LessonScoreLine(lesson: .biggerPicture, results: results, fallback: BiggerPicture.scoreLine(for: score))

			BiggerPictureContinueButton(identifier: "quiz", action: onContinue)
				.padding(.top, 12)
		}
		.frame(maxWidth: .infinity)
		.padding(.top, 12)
	}
}
