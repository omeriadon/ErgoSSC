//
//  BiggerPictureYourTurnPage.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Page 3: three headlines, each fair or cherry-picked, and each chart zooms out once answered
struct BiggerPictureYourTurnPage: View {
	@Default(.biggerPictureState) private var state

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	/// Long enough for the chart to zoom out, show what it hid, and its explanation to be read
	private let nextDelay = 4.6

	private var visible: [BiggerPictureQuizItem] {
		Array(BiggerPicture.quiz.prefix(state.quizPicks.count + 1))
	}

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				content
					.padding()
			}
			.onChange(of: state.quizPicks.count) { old, new in
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
				BiggerPictureQuizCard(item: item, pick: pick(for: item)) { isFair in
					answer(item, isFair: isFair)
				}
				.id(item.id)
				.transition(.opacity.combined(with: .offset(y: 24)))
			}

			if state.quizFinished {
				BiggerPictureScore(score: state.quizScore) {
					state.page = .summary
				}
				.id("continue")
				.transition(.opacity)
			}

			// Room to scroll past the end
			Color.clear
				.frame(height: 250)
		}
		.animation(reduceMotion ? .easeInOut(duration: 0.25) : .smooth(duration: 0.6).delay(nextDelay), value: state.quizPicks.count)
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
		let finished = state.quizFinished
		let next = state.quizPicks.count
		Task {
			try? await Task.sleep(for: .seconds(nextDelay + 0.2))
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
	let onPick: (Bool) -> Void

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	/// Local, so the zoom can play after the pick
	@State private var visibleFrom: Int
	/// Zoomed out, a cherry-picked chart shows the usual line and what was special about its start
	@State private var showsReveal: Bool
	@State private var showsExplanation: Bool

	init(item: BiggerPictureQuizItem, pick: Bool?, onPick: @escaping (Bool) -> Void) {
		self.item = item
		self.pick = pick
		self.onPick = onPick
		_visibleFrom = State(initialValue: pick == nil ? item.pickedFrom : BiggerPicture.firstYear)
		_showsReveal = State(initialValue: pick != nil && !item.isFair)
		_showsExplanation = State(initialValue: pick != nil)
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
				.font(.title3.bold())
				.fontDesign(.serif)
				.fixedSize(horizontal: false, vertical: true)

			BiggerPictureChart(
				points: item.points,
				measure: item.measure,
				visibleFrom: visibleFrom,
				highlighted: highlighted,
				usual: showsReveal ? item.usual : nil,
				note: showsReveal ? item.pickNote.map { (year: item.pickedFrom, text: $0) } : nil,
				height: 150
			)
			.overlay(alignment: .topTrailing) {
				if showsReveal {
					Label("Zoomed out", systemImage: "arrow.up.left.and.arrow.down.right")
						.font(.caption.weight(.semibold))
						.padding(.horizontal, 10)
						.padding(.vertical, 5)
						.background(.orange.opacity(0.2), in: .capsule)
						.foregroundStyle(.orange)
						.transition(.scale(0.8).combined(with: .opacity))
				}
			}

			Text(item.measure)
				.font(.caption)
				.foregroundStyle(.secondary)
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(.background.secondary, in: .rect(cornerRadius: 18))
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(item.headline)
		.accessibilityValue(chartDescription)
	}

	/// Before an answer, every bar shown is lit. Once zoomed out, only the headline's window is.
	private var highlighted: Set<Int> {
		let window = item.points.map(\.year).filter { $0 >= item.pickedFrom }
		return Set(window)
	}

	private var chartDescription: String {
		item.points
			.filter { $0.year >= visibleFrom }
			.map { "\($0.year): \(Int($0.value))" }
			.joined(separator: ", ")
	}

	private var result: some View {
		VStack(alignment: .leading, spacing: 4) {
			Label(resultTitle, systemImage: isRight ? "checkmark.circle.fill" : "xmark.circle.fill")
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
				showsReveal = !item.isFair
				showsExplanation = true
			}
			return
		}

		try? await Task.sleep(for: .seconds(0.5))
		for year in stride(from: visibleFrom - 1, through: BiggerPicture.firstYear, by: -1) {
			withAnimation(.smooth(duration: 0.4)) {
				visibleFrom = year
			}
			try? await Task.sleep(for: .seconds(0.15))
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
				.background(fillColor, in: .capsule)
				.overlay {
					Capsule()
						.strokeBorder(isLocked && isPicked && !isAnswer ? Color.orange : .clear, lineWidth: 1.5)
				}
				.contentShape(.capsule)
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
	let onContinue: () -> Void

	var body: some View {
		VStack(spacing: 10) {
			Text("\(score) of \(BiggerPicture.quiz.count)")
				.font(.largeTitle.bold().monospacedDigit())

			Text(BiggerPicture.scoreLine(for: score))
				.font(.body)
				.multilineTextAlignment(.center)
				.foregroundStyle(.secondary)
				.fixedSize(horizontal: false, vertical: true)

			BiggerPictureContinueButton(identifier: "quiz", action: onContinue)
				.padding(.top, 12)
		}
		.frame(maxWidth: .infinity)
		.padding(.top, 12)
	}
}
