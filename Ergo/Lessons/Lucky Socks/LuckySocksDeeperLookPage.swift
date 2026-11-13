//
//  LuckySocksDeeperLookPage.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Page 2: a claim that holds up. Jess remembers one box, and each of the other three is tapped to count it.
struct LuckySocksDeeperLookPage: View {
	@Default(.luckySocksState) private var state

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	/// Local, so the result comes in after the last count has registered, not with it
	@State private var showsResult: Bool

	init() {
		_showsResult = State(initialValue: Defaults[.luckySocksState].countedAll)
	}

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				VStack(alignment: .leading, spacing: 24) {
					LuckySocksMessage(id: "jess.sleep", text: LuckySocks.sleepMessage)

					Text(LuckySocks.sleepPrompt)
						.font(.headline)
						.fixedSize(horizontal: false, vertical: true)

					grid

					if showsResult {
						result
							.id("result")
							.transition(.opacity.combined(with: .offset(y: 20)))
					}
				}
				.padding()
			}
			.onChange(of: showsResult) { _, shows in
				guard shows else { return }
				Task {
					try? await Task.sleep(for: .seconds(0.9))
					withAnimation(reduceMotion ? nil : .smooth(duration: 0.8)) {
						proxy.scrollTo("result", anchor: .bottom)
					}
				}
			}
		}
		.navigationTitle(lessonTitle(.luckySocks, "Deeper look"))
		.sensoryFeedback(.selection, trigger: state.countedBoxes)
	}

	private var grid: some View {
		FourBoxGrid(labels: LuckySocks.sleepLabels) { box in
			LuckySocksCountBox(
				count: LuckySocks.weekCounts[box],
				isCounted: box == .both || state.countedBoxes.contains(box),
				isRemembered: box == .both
			) {
				count(box)
			}
			.accessibilityIdentifier("learn.luckySocks.box.\(box.rawValue)")
		}
	}

	private var result: some View {
		VStack(alignment: .leading, spacing: 16) {
			FourBoxComparison(labels: LuckySocks.sleepLabels, counts: LuckySocks.weekCounts)

			Text(LuckySocks.sleepLine)
				.font(.title3)
				.fixedSize(horizontal: false, vertical: true)

			LuckySocksContinueButton(identifier: "deeperLook") {
				state.page = .yourTurn
			}
			.padding(.top, 8)
		}
	}

	private func count(_ box: FourBox) {
		guard !state.countedBoxes.contains(box) else { return }
		withAnimation(.smooth(duration: 0.35)) {
			_ = state.countedBoxes.insert(box)
		}

		guard state.countedAll else { return }
		Task {
			// A moment with all four counts before the comparison arrives
			try? await Task.sleep(for: .seconds(0.8))
			withAnimation(.smooth(duration: 0.6)) {
				showsResult = true
			}
		}
	}
}

/// One box on page 2: its count once counted, or a question mark to tap
private struct LuckySocksCountBox: View {
	let count: Int
	let isCounted: Bool
	/// The box Jess remembers, already counted
	let isRemembered: Bool
	let onCount: () -> Void

	var body: some View {
		Button(action: onCount) {
			VStack(spacing: 2) {
				Text(isCounted ? "\(count)" : "?")
					.font(.title2.bold().monospacedDigit())
					.foregroundStyle(isCounted ? .primary : .secondary)
					.contentTransition(.numericText())

				Text(isRemembered ? "Remembered" : isCounted ? "days" : "Tap to count")
					.font(.caption2)
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, minHeight: 64)
			.padding(.vertical, 6)
			.background {
				FourBoxBackground(isLit: isCounted)
			}
			.contentShape(.rect(cornerRadius: 14))
		}
		.buttonStyle(.plain)
		.disabled(isCounted)
		.accessibilityValue(isCounted ? "\(count) days" : "Not counted")
		.accessibilityHint(isCounted ? "" : "Counts the days in this box")
	}
}
