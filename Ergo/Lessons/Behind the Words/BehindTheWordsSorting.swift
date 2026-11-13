//
//  BehindTheWordsSorting.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

// MARK: - Question 2

/// One row per part that isn't the claim, each sorted into reason or filler
struct BehindTheWordsSortQuestion: View {
	let picks: [Int: BehindTheWordsKind]
	let onPick: (BehindTheWordsKind, BehindTheWordsUnit) -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			BehindTheWordsQuestionHeading(number: 2, text: "So what are the other parts?")

			ForEach(BehindTheWords.sortable) { unit in
				BehindTheWordsSortRow(unit: unit, pick: picks[unit.number]) { kind in
					onPick(kind, unit)
				}
			}
		}
		.sensoryFeedback(trigger: picks) { old, new in
			feedback(old: old, new: new)
		}
	}

	/// Success for a right pick, a warning for a wrong one
	private func feedback(old: [Int: BehindTheWordsKind], new: [Int: BehindTheWordsKind]) -> SensoryFeedback? {
		guard let number = new.keys.first(where: { old[$0] == nil }),
		      let unit = BehindTheWords.units.first(where: { $0.number == number })
		else {
			return nil
		}
		return new[number] == unit.kind ? .success : .warning
	}
}

private struct BehindTheWordsSortRow: View {
	let unit: BehindTheWordsUnit
	let pick: BehindTheWordsKind?
	let onPick: (BehindTheWordsKind) -> Void

	private var isWrong: Bool {
		pick != nil && pick != unit.kind
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			header

			HStack(spacing: 8) {
				option(.reason)
				option(.filler)
			}

			if isWrong {
				Label(unit.hint, systemImage: "lightbulb")
					.font(.subheadline)
					.foregroundStyle(.orange)
					.fixedSize(horizontal: false, vertical: true)
					.transition(.opacity)
			}
		}
		.padding(14)
		.background(.background.secondary, in: .rect(cornerRadius: 18))
		.animation(.smooth(duration: 0.3), value: pick)
	}

	private var header: some View {
		HStack(alignment: .firstTextBaseline, spacing: 10) {
			Text("\(unit.number)")
				.font(.caption.bold().monospacedDigit())
				.foregroundStyle(.secondary)
				.frame(width: 22, height: 22)
				.background(.quaternary, in: .circle)

			Text(unit.text)
				.font(.subheadline)
				.frame(maxWidth: .infinity, alignment: .leading)
				.fixedSize(horizontal: false, vertical: true)

			if let pick {
				Image(systemName: pick == unit.kind ? "checkmark.circle.fill" : "xmark.circle.fill")
					.foregroundStyle(pick == unit.kind ? .green : .red)
					.accessibilityLabel(pick == unit.kind ? "Right" : "Not quite")
					.transition(.scale.combined(with: .opacity))
			}
		}
		.accessibilityElement(children: .combine)
	}

	private func option(_ kind: BehindTheWordsKind) -> some View {
		BehindTheWordsSortOption(kind: kind, answer: unit.kind, pick: pick) {
			onPick(kind)
		}
		.accessibilityIdentifier("learn.behindTheWords.sort.\(unit.number).\(kind.rawValue)")
	}
}

/// "Reason" or "Filler". Once picked, the right one is filled in and the row is locked.
private struct BehindTheWordsSortOption: View {
	let kind: BehindTheWordsKind
	let answer: BehindTheWordsKind
	let pick: BehindTheWordsKind?
	let action: () -> Void

	private var isLocked: Bool {
		pick != nil
	}

	private var isAnswer: Bool {
		kind == answer
	}

	var body: some View {
		Button(action: action) {
			Text(kind.name)
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(textColor)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 10)
				.background(fillColor, in: .rect(cornerRadius: 12))
				.overlay {
					RoundedRectangle(cornerRadius: 12)
						.strokeBorder(strokeColor, lineWidth: 1.5)
				}
				.contentShape(.rect(cornerRadius: 12))
		}
		.buttonStyle(BehindTheWordsPressStyle())
		.disabled(isLocked)
		.accessibilityValue(voiceOverValue)
	}

	private var fillColor: Color {
		guard isLocked else {
			return .primary.opacity(0.06)
		}
		return isAnswer ? kind.color : .clear
	}

	private var textColor: Color {
		guard isLocked else {
			return .primary
		}
		if isAnswer {
			return .white
		}
		return pick == kind ? .red : .secondary
	}

	private var strokeColor: Color {
		isLocked && !isAnswer && pick == kind ? .red.opacity(0.6) : .clear
	}

	private var voiceOverValue: String {
		guard isLocked else {
			return ""
		}
		if isAnswer {
			return "Right answer"
		}
		return pick == kind ? "Your pick, not quite" : ""
	}
}

// MARK: - The skeleton

/// What's left of the reply once the filler is gone
struct BehindTheWordsSkeleton: View {
	/// Steps in one by one, rather than already being there when the page reopens
	let animated: Bool
	let onContinue: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 22) {
			Text("The friendly bits make it nice to read. The reasons are what make it worth listening to.")
				.font(.title3)
				.fixedSize(horizontal: false, vertical: true)
				.modifier(BehindTheWordsReveal(delay: 2.4, animated: animated))

			skeleton
				.modifier(BehindTheWordsReveal(delay: 3.2, animated: animated))

			Text(BehindTheWords.countLine)
				.font(.footnote.weight(.medium).monospacedDigit())
				.foregroundStyle(.secondary)
				.frame(maxWidth: .infinity)
				.modifier(BehindTheWordsReveal(delay: 3.9, animated: animated))

			BehindTheWordsContinueButton(identifier: "skeleton", action: onContinue)
				.modifier(BehindTheWordsReveal(delay: 4.4, animated: animated))
		}
	}

	private var skeleton: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("**What it wants:** go to Little Bird.")
				.padding(12)
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(BehindTheWordsKind.claim.color.opacity(0.15), in: .rect(cornerRadius: 14))

			Text("**Why:** $4.50 flat whites · beans roasted every morning · open before 7.")
				.padding(12)
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(BehindTheWordsKind.reason.color.opacity(0.15), in: .rect(cornerRadius: 14))
		}
		.fixedSize(horizontal: false, vertical: true)
	}
}

/// Fades a part of the skeleton in after the passage has collapsed
private struct BehindTheWordsReveal: ViewModifier {
	let delay: Double
	let animated: Bool

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	@State private var shown = false

	func body(content: Content) -> some View {
		content
			.opacity(shown ? 1 : 0)
			.offset(y: shown || reduceMotion ? 0 : 14)
			.onAppear {
				guard animated, !shown else {
					shown = true
					return
				}
				let pace = reduceMotion ? delay * 0.5 : delay
				withAnimation(.smooth(duration: 0.6).delay(pace)) {
					shown = true
				}
			}
	}
}
