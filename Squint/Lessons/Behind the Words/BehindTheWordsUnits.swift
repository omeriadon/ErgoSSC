//
//  BehindTheWordsUnits.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

/// How far page 2 has got, which decides how each part of the reply looks
nonisolated enum BehindTheWordsPhase: Hashable, Sendable {
	/// Looking for the claim
	case finding
	/// The claim is found, and the rest are being sorted
	case sorting
	/// Down to the skeleton
	case skeleton
}

/// The reply split into its numbered parts. Tapping one answers question 1.
struct BehindTheWordsUnitList: View {
	let phase: BehindTheWordsPhase
	/// False draws it as one paragraph, before it breaks apart
	let isSplit: Bool
	let flashing: Int?
	let onTap: (BehindTheWordsUnit) -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: isSplit ? 8 : 0) {
			ForEach(BehindTheWords.units) { unit in
				BehindTheWordsUnitRow(
					unit: unit,
					phase: phase,
					isSplit: isSplit,
					isFlashing: flashing == unit.number
				) {
					onTap(unit)
				}
			}
		}
	}
}

private struct BehindTheWordsUnitRow: View {
	let unit: BehindTheWordsUnit
	let phase: BehindTheWordsPhase
	let isSplit: Bool
	let isFlashing: Bool
	let onTap: () -> Void

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	private var isFiller: Bool {
		unit.kind == .filler
	}

	var body: some View {
		Button(action: onTap) {
			label
		}
		.buttonStyle(BehindTheWordsPressStyle())
		.disabled(phase != .finding)
		.opacity(unitOpacity)
		.blur(radius: phase == .skeleton && isFiller ? 0.6 : 0)
		.scaleEffect(unitScale, anchor: .leading)
		.animation(.easeOut(duration: 0.25), value: isFlashing)
		.animation(phaseAnimation, value: phase)
		.accessibilityLabel(voiceOverLabel)
		.accessibilityIdentifier("learn.behindTheWords.unit.\(unit.number)")
	}

	private var label: some View {
		HStack(alignment: .firstTextBaseline, spacing: isSplit ? 10 : 0) {
			badge

			Text(unit.text)
				.frame(maxWidth: .infinity, alignment: .leading)
				.fixedSize(horizontal: false, vertical: true)
				.multilineTextAlignment(.leading)

			if phase == .skeleton {
				BehindTheWordsKindTag(kind: unit.kind)
					.transition(.opacity)
			}
		}
		.padding(.vertical, isSplit ? 10 : 0)
		.padding(.horizontal, isSplit ? 12 : 0)
		.background(fill, in: .rect(cornerRadius: 14))
		.contentShape(.rect)
	}

	private var badge: some View {
		Text("\(unit.number)")
			.font(.caption.bold().monospacedDigit())
			.foregroundStyle(.secondary)
			.frame(width: isSplit ? 22 : 0, height: 22)
			.background(.quaternary, in: .circle)
			.opacity(isSplit ? 1 : 0)
			.accessibilityHidden(true)
	}

	private var fill: Color {
		if isFlashing {
			return .red.opacity(0.3)
		}
		guard isSplit else {
			return .clear
		}
		switch phase {
			case .finding:
				return .primary.opacity(0.05)
			case .sorting:
				return unit.kind == .claim ? .green.opacity(0.22) : .primary.opacity(0.04)
			case .skeleton:
				return isFiller ? .clear : unit.kind.color.opacity(0.18)
		}
	}

	private var unitOpacity: Double {
		switch phase {
			case .finding: 1
			case .sorting: unit.kind == .claim ? 1 : 0.6
			case .skeleton: isFiller ? 0.22 : 1
		}
	}

	private var unitScale: CGFloat {
		phase == .skeleton && isFiller && !reduceMotion ? 0.96 : 1
	}

	/// The skeleton's stagger: the filler fades first, then what's left lights up
	private var phaseAnimation: Animation {
		guard phase == .skeleton, !reduceMotion else {
			return .easeInOut(duration: 0.3)
		}
		let order = Double(unit.number - 1)
		let delay = isFiller ? 0.6 + order * 0.1 : 1.4 + order * 0.15
		return .smooth(duration: 0.8).delay(delay)
	}

	private var voiceOverLabel: String {
		let base = "Part \(unit.number): \(unit.text)"
		switch phase {
			case .finding:
				return base
			case .sorting:
				return unit.kind == .claim ? "\(base). Claim" : base
			case .skeleton:
				return "\(base). \(unit.kind.name)"
		}
	}
}

/// A small label naming what a part is
struct BehindTheWordsKindTag: View {
	let kind: BehindTheWordsKind

	var body: some View {
		Text(kind.name)
			.font(.caption2.weight(.bold))
			.textCase(.uppercase)
			.foregroundStyle(kind.color)
			.padding(.horizontal, 7)
			.padding(.vertical, 3)
			.background(kind.color.opacity(0.15), in: .rect(cornerRadius: 5))
			.fixedSize()
	}
}

/// Shrinks a little while held, and never greys out when disabled
struct BehindTheWordsPressStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.98 : 1)
			.animation(.snappy(duration: 0.15), value: configuration.isPressed)
	}
}
