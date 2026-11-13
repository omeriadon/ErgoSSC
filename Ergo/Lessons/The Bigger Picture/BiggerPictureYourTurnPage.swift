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

	/// Long enough for the chart to zoom out and its explanation to be read
	private let nextDelay = 3.0

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
				BiggerPictureContinueButton(identifier: "yourTurn") {
					state.page = .summary
				}
				.id("continue")
				.transition(.opacity)
			}
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
					proxy.scrollTo("continue", anchor: .bottom)
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
	@State private var showsExplanation: Bool

	init(item: BiggerPictureQuizItem, pick: Bool?, onPick: @escaping (Bool) -> Void) {
		self.item = item
		self.pick = pick
		self.onPick = onPick
		_visibleFrom = State(initialValue: pick == nil ? item.pickedFrom : BiggerPicture.firstYear)
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
				highlighted: [item.pickedFrom, BiggerPicture.lastYear],
				height: 150
			)

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

	private var chartDescription: String {
		item.points
			.filter { $0.year >= visibleFrom }
			.map { "\($0.year): \(Int($0.value))" }
			.joined(separator: ", ")
	}

	private var result: some View {
		VStack(alignment: .leading, spacing: 4) {
			Label(isRight ? "That's right." : "Not quite.", systemImage: isRight ? "checkmark.circle.fill" : "xmark.circle.fill")
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(isRight ? .green : .orange)

			Text(item.explanation)
				.font(.subheadline)
				.fixedSize(horizontal: false, vertical: true)
		}
		.accessibilityElement(children: .combine)
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

		try? await Task.sleep(for: .seconds(0.4))
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
