//
//  BiggerPictureDeeperLookPage.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Page 2: drag where the counting starts, and watch the headline change
struct BiggerPictureDeeperLookPage: View {
	@Default(.biggerPictureState) private var state

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	/// Local, so the comparison comes in after the find has registered, not with it
	@State private var showsComparison: Bool

	init() {
		_showsComparison = State(initialValue: Defaults[.biggerPictureState].foundBest)
	}

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				VStack(alignment: .leading, spacing: 24) {
					Text("Drag along the chart to find the start year that makes the cameras look best.")
						.font(.headline)
						.fixedSize(horizontal: false, vertical: true)

					article

					countingLabel

					if showsComparison {
						comparison
							.id("comparison")
							.transition(.opacity.combined(with: .offset(y: 20)))
					}
				}
				.padding()
			}
			.onChange(of: showsComparison) { _, shows in
				guard shows else { return }
				Task {
					try? await Task.sleep(for: .seconds(0.9))
					withAnimation(reduceMotion ? nil : .smooth(duration: 0.8)) {
						proxy.scrollTo("comparison", anchor: .bottom)
					}
				}
			}
		}
		.navigationTitle(lessonTitle(.biggerPicture, "Deeper look"))
		.sensoryFeedback(.selection, trigger: state.countingFrom)
		.sensoryFeedback(.success, trigger: state.foundBest) { _, found in
			found
		}
	}

	private var article: some View {
		BiggerPictureArticle(headline: BiggerPicture.headline(from: state.countingFrom), reservesTwoLines: true) {
			BiggerPictureChart(
				points: BiggerPicture.crashes,
				measure: BiggerPicture.measure,
				visibleFrom: BiggerPicture.firstYear,
				highlighted: [state.countingFrom, BiggerPicture.lastYear],
				countingFrom: state.countingFrom,
				comparison: showsComparison ? BiggerPicture.otherRoads : nil,
				onPick: pick
			)
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(BiggerPicture.headline(from: state.countingFrom))
		.accessibilityValue("Counting from \(state.countingFrom)")
		.accessibilityAdjustableAction { direction in
			switch direction {
				case .increment: pick(state.countingFrom + 1)
				case .decrement: pick(state.countingFrom - 1)
				@unknown default: break
			}
		}
		.accessibilityIdentifier("learn.biggerPicture.chart")
	}

	private var countingLabel: some View {
		Label {
			Text("Counting from **\(String(state.countingFrom))**")
				.contentTransition(.numericText())
		} icon: {
			Image(systemName: "hand.draw")
		}
		.font(.subheadline)
		.foregroundStyle(.secondary)
		.frame(maxWidth: .infinity)
	}

	private var comparison: some View {
		VStack(alignment: .leading, spacing: 16) {
			Label("That's the one. From 2023, the cameras look like they halved the crashes.", systemImage: "checkmark.circle.fill")
				.font(.headline)
				.foregroundStyle(.green)
				.fixedSize(horizontal: false, vertical: true)

			HStack(alignment: .firstTextBaseline, spacing: 10) {
				Image(systemName: "line.diagonal")
					.foregroundStyle(.secondary)
				Text(BiggerPicture.comparisonLine)
					.font(.body)
					.fixedSize(horizontal: false, vertical: true)
			}
			.padding(14)
			.background(.background.secondary, in: .rect(cornerRadius: 16))

			BiggerPictureContinueButton(identifier: "deeperLook") {
				state.page = .yourTurn
			}
		}
	}

	// MARK: - Actions

	/// Counting can start anywhere but the last year
	private func pick(_ year: Int) {
		let year = min(max(year, BiggerPicture.firstYear), BiggerPicture.lastYear - 1)
		guard year != state.countingFrom else { return }

		withAnimation(.smooth(duration: 0.25)) {
			state.countingFrom = year
		}

		guard year == BiggerPicture.spikeYear, !state.foundBest else { return }
		state.foundBest = true
		Task {
			// A moment with the "halved" headline before the comparison arrives
			try? await Task.sleep(for: .seconds(1.2))
			withAnimation(.smooth(duration: 0.7)) {
				showsComparison = true
			}
		}
	}
}
