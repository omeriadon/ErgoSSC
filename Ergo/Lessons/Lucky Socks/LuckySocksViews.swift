//
//  LuckySocksViews.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

/// The four boxes: a row for each side of the first thing, and a column for each side of the second
struct FourBoxGrid<Cell: View>: View {
	let labels: FourBoxLabels
	@ViewBuilder var cell: (FourBox) -> Cell

	var body: some View {
		Grid(horizontalSpacing: 8, verticalSpacing: 8) {
			GridRow {
				Color.clear
					.gridCellUnsizedAxes([.horizontal, .vertical])
				columnHeader(labels.second)
				columnHeader(labels.notSecond)
			}

			GridRow {
				rowHeader(labels.first)
				cell(.both)
				cell(.firstOnly)
			}

			GridRow {
				rowHeader(labels.notFirst)
				cell(.secondOnly)
				cell(.neither)
			}
		}
	}

	private func columnHeader(_ text: String) -> some View {
		Text(text)
			.font(.caption.weight(.semibold))
			.foregroundStyle(.secondary)
			.frame(maxWidth: .infinity)
	}

	private func rowHeader(_ text: String) -> some View {
		Text(text)
			.font(.caption.weight(.semibold))
			.foregroundStyle(.secondary)
			.multilineTextAlignment(.leading)
			.frame(width: 64, alignment: .leading)
	}
}

/// A box's background: lit in the lesson's colour, or faint
struct FourBoxBackground: View {
	let isLit: Bool

	var body: some View {
		RoundedRectangle(cornerRadius: 14)
			.fill(isLit ? AnyShapeStyle(Lesson.luckySocks.tint.opacity(0.2)) : AnyShapeStyle(.background.secondary))
	}
}

/// The two rates the four boxes give, one under the other
struct FourBoxComparison: View {
	let labels: FourBoxLabels
	let counts: FourBoxCounts

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			line(labels.first, hits: counts.both, out: counts.both + counts.firstOnly)
			line(labels.notFirst, hits: counts.secondOnly, out: counts.secondOnly + counts.neither)
		}
		.font(.body.monospacedDigit())
		.accessibilityElement(children: .combine)
	}

	private func line(_ row: String, hits: Int, out total: Int) -> some View {
		let percent = Int((Double(hits) / Double(max(1, total)) * 100).rounded())
		return Text("\(row): **\(labels.second.lowercased()) \(hits) of \(total)** (\(percent)%)")
	}
}

/// A message from Jess, in lesson 2's bubbles
struct LuckySocksMessage: View {
	let id: String
	let text: String

	var body: some View {
		HStack(alignment: .bottom, spacing: 8) {
			ChatAvatar(name: LuckySocks.friend, size: 32)

			ChatBubble(message: ChatMessage(id: id, sender: .contact, text: text), hasTail: true)

			Spacer(minLength: 40)
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("\(LuckySocks.friend): \(text)")
	}
}

/// One game, small enough for four to sit in a box: whether the socks were on, and the result
struct LuckySocksGameCard: View {
	let game: LuckySocksGame

	var body: some View {
		VStack(spacing: 1) {
			Text(game.socks ? "🧦" : "–")
				.font(.caption2)
				.foregroundStyle(.secondary)

			Text(game.won ? "W" : "L")
				.font(.caption.bold())
				.foregroundStyle(game.won ? Lesson.luckySocks.tint : .secondary)
		}
		.frame(width: 28, height: 38)
		.background(.background, in: .rect(cornerRadius: 7))
		.overlay {
			RoundedRectangle(cornerRadius: 7)
				.strokeBorder(.quaternary, lineWidth: 1)
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("Game \(game.id): \(game.socks ? "socks on" : "no socks"), \(game.won ? "won" : "lost")")
	}
}

/// The full-width button that moves the lesson on
struct LuckySocksContinueButton: View {
	var title = "Continue"
	let identifier: String
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Text(title)
				.font(.headline)
				.frame(maxWidth: .infinity)
		}
		.buttonStyle(.glassProminent)
		.buttonBorderShape(.roundedRectangle(radius: 12))
		.controlSize(.large)
		.accessibilityIdentifier("learn.luckySocks.continue.\(identifier)")
	}
}

/// A term the lesson teaches, with its symbol and what it means
struct LuckySocksTermRow: View {
	let name: String
	let symbol: String
	let definition: String

	private let tint = Lesson.luckySocks.tint

	var body: some View {
		HStack(alignment: .firstTextBaseline, spacing: 12) {
			Image(systemName: symbol)
				.foregroundStyle(tint)
				.frame(width: 22)

			VStack(alignment: .leading, spacing: 2) {
				Text(name)
					.font(.headline)
					.foregroundStyle(tint)

				Text(definition)
					.font(.body)
					.fixedSize(horizontal: false, vertical: true)
			}

			Spacer(minLength: 0)
		}
		.padding(14)
		.background(tint.opacity(0.12), in: .rect(cornerRadius: 16))
		.accessibilityElement(children: .combine)
	}
}
