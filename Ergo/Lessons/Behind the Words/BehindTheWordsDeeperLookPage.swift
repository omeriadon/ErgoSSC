//
//  BehindTheWordsDeeperLookPage.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Page 2: find the claim, sort the rest, then see the reply collapse to its skeleton
struct BehindTheWordsDeeperLookPage: View {
	@Default(.behindTheWordsState) private var state

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	/// The reply breaks into its parts just after the page opens
	@State private var isSplit = false
	/// The part just tapped wrongly, flashing red
	@State private var flashing: Int?
	/// The collapse happened here, rather than being reopened
	@State private var collapsedLive = false

	private var phase: BehindTheWordsPhase {
		if state.showsSkeleton {
			.skeleton
		} else if state.claimFound {
			.sorting
		} else {
			.finding
		}
	}

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				content
					.padding()
			}
			.onChange(of: state.claimFound) { _, found in
				guard found else { return }
				scroll(proxy, to: "question2", after: 1.1)
			}
			.onChange(of: state.showsSkeleton) { _, shows in
				guard shows else { return }
				collapsedLive = true
				scroll(proxy, to: "passage", after: 0)
			}
		}
		.navigationTitle(lessonTitle(.behindTheWords, "Deeper look"))
		.sensoryFeedback(.success, trigger: state.claimFound) { _, found in
			found
		}
		.sensoryFeedback(.error, trigger: state.claimMisses) { old, new in
			new > old
		}
		.onAppear(perform: appear)
	}

	private var content: some View {
		VStack(alignment: .leading, spacing: 28) {
			BehindTheWordsForumReply {
				BehindTheWordsUnitList(phase: phase, isSplit: isSplit, flashing: flashing, onTap: tap)
			}
			.id("passage")

			if state.showsSkeleton {
				BehindTheWordsSkeleton(animated: collapsedLive) {
					state.page = .yourTurn
				}
				.transition(.opacity.animation(.smooth(duration: 0.5).delay(0.5)))
			} else {
				questions
					.transition(.opacity)
			}
		}
		.animation(reduceMotion ? .easeInOut(duration: 0.25) : .smooth(duration: 0.5), value: state.showsSkeleton)
		.animation(.smooth(duration: 0.4), value: state.claimFound)
	}

	private var questions: some View {
		VStack(alignment: .leading, spacing: 32) {
			BehindTheWordsClaimQuestion(found: state.claimFound, missed: state.claimMisses > 0)

			if state.claimFound {
				// After the claim has turned green, so the two don't happen at once
				BehindTheWordsSortQuestion(picks: state.sorted, onPick: pick)
					.id("question2")
					.transition(.opacity.combined(with: .offset(y: 20)).animation(.smooth(duration: 0.6).delay(0.7)))
			}
		}
	}

	// MARK: - Actions

	private func appear() {
		// Leaving during the pause before the collapse still reopens on the skeleton
		if state.allSorted, !state.showsSkeleton {
			state.showsSkeleton = true
		}

		let started = state.claimFound || state.claimMisses > 0
		guard !isSplit else { return }
		if reduceMotion || started {
			isSplit = true
		} else {
			withAnimation(.smooth(duration: 0.8).delay(0.9)) {
				isSplit = true
			}
		}
	}

	private func tap(_ unit: BehindTheWordsUnit) {
		guard !state.claimFound else { return }

		if unit.kind == .claim {
			flashing = nil
			state.claimFound = true
		} else {
			state.claimMisses += 1
			flashing = unit.number
			Task {
				try? await Task.sleep(for: .seconds(0.6))
				if flashing == unit.number {
					flashing = nil
				}
			}
		}
	}

	private func pick(_ kind: BehindTheWordsKind, for unit: BehindTheWordsUnit) {
		guard state.sorted[unit.number] == nil else { return }
		state.sorted[unit.number] = kind

		guard state.allSorted else { return }
		// A pause to read the last answer, longer if it needs its hint read
		let pause = kind == unit.kind ? 1.8 : 3.2
		Task {
			try? await Task.sleep(for: .seconds(pause))
			if !state.showsSkeleton {
				state.showsSkeleton = true
			}
		}
	}

	private func scroll(_ proxy: ScrollViewProxy, to id: String, after delay: Double) {
		Task {
			try? await Task.sleep(for: .seconds(delay))
			withAnimation(reduceMotion ? nil : .smooth(duration: 0.6)) {
				proxy.scrollTo(id, anchor: .top)
			}
		}
	}
}

// MARK: - Question 1

private struct BehindTheWordsClaimQuestion: View {
	let found: Bool
	let missed: Bool

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			BehindTheWordsQuestionHeading(number: 1, text: "Which part here actually says what it wants you to do?")

			if found {
				Text("That's the claim.")
					.foregroundStyle(.green)
					.transition(.opacity)
			} else if missed {
				Label(BehindTheWords.claimHint, systemImage: "questionmark.circle")
					.foregroundStyle(.orange)
					.transition(.opacity)
			} else {
				Text("Tap it in the reply.")
					.foregroundStyle(.secondary)
					.transition(.opacity)
			}
		}
		.font(.subheadline)
		.animation(.easeInOut(duration: 0.25), value: found)
		.animation(.easeInOut(duration: 0.25), value: missed)
	}
}

/// "1" in a circle, then the question
struct BehindTheWordsQuestionHeading: View {
	let number: Int
	let text: String

	var body: some View {
		HStack(alignment: .firstTextBaseline, spacing: 10) {
			Image(systemName: "\(number).circle.fill")
				.foregroundStyle(.tint)
				.accessibilityHidden(true)

			Text(text)
				.font(.headline)
				.fixedSize(horizontal: false, vertical: true)
		}
		.accessibilityElement(children: .combine)
		.accessibilityAddTraits(.isHeader)
	}
}
