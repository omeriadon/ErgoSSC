//
//  BiggerPictureDeeperLookPage.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Page 2: pinch the chart to choose where the counting starts, and watch the headline change
struct BiggerPictureDeeperLookPage: View {
	@Default(.biggerPictureState) private var state

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	/// Local, so the comparison comes in after the find has registered, not with it
	@State private var showsComparison: Bool
	/// Where the counting started when the pinch began
	@State private var pinchStart: Int?

	init() {
		_showsComparison = State(initialValue: Defaults[.biggerPictureState].foundBest)
	}

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				VStack(alignment: .leading, spacing: 29) {
					Text("Pinch the chart to zoom in, and find the start year that makes the cameras look best.")
						.font(.headline)
						.fixedSize(horizontal: false, vertical: true)

					article

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
				visibleFrom: state.countingFrom,
				highlighted: [state.countingFrom, BiggerPicture.lastYear],
				comparison: showsComparison ? BiggerPicture.otherRoads : nil
			)
			.contentShape(.rect)
			.gesture(pinch)
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

	private var comparison: some View {
		VStack(alignment: .leading, spacing: 21) {
			Text("That's the one. From 2023, the cameras look like they halved the crashes.")
				.font(.headline)
				.foregroundStyle(.green)
				.fixedSize(horizontal: false, vertical: true)

			Text(BiggerPicture.comparisonLine)
				.font(.body)
				.fixedSize(horizontal: false, vertical: true)
				.padding(14)
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(.background.secondary, in: .rect(cornerRadius: 16))

			BiggerPictureContinueButton(identifier: "deeperLook") {
				state.page = .yourTurn
			}
		}
	}

	// MARK: - Zooming

	/// Pinned to the last year: spreading the fingers shows fewer years, pinching shows more
	private var pinch: some Gesture {
		MagnifyGesture()
			.onChanged { value in
				let start = pinchStart ?? state.countingFrom
				pinchStart = start
				let years = Double(BiggerPicture.lastYear - start + 1)
				let shown = Int((years / value.magnification).rounded())
				pick(BiggerPicture.lastYear - shown + 1)
			}
			.onEnded { _ in
				pinchStart = nil
			}
	}

	// MARK: - Actions

	/// Counting can start anywhere but the last year
	private func pick(_ year: Int) {
		let year = min(max(year, BiggerPicture.firstYear), BiggerPicture.lastYear - 1)
		guard year != state.countingFrom else { return }

		withAnimation(.smooth(duration: 0.3)) {
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
