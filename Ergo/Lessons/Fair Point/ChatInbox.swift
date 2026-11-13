//
//  ChatInbox.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

/// An inbox that scrolls by on its own, slows, lands on one row and opens it. Slow enough to read the names as they pass.
struct ChatInbox: View {
	let rows: [InboxRow]
	let landingRow: String
	let onOpen: () -> Void

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	@State private var hasLanded = false
	@State private var isHighlighted = false

	private let rowHeight: CGFloat = 72
	private let visibleRows = 4

	var body: some View {
		VStack(spacing: 0) {
			ForEach(rows) { row in
				InboxRowView(row: row, isHighlighted: isHighlighted && row.id == landingRow)
					.frame(height: rowHeight)
			}
		}
		.fixedSize(horizontal: false, vertical: true)
		.offset(y: hasLanded ? -landingOffset : 0)
		.frame(height: rowHeight * CGFloat(visibleRows), alignment: .top)
		.clipped()
		.padding(.horizontal, 12)
		.background(Color(.systemBackground), in: .rect(cornerRadius: 24))
		.overlay {
			RoundedRectangle(cornerRadius: 24)
				.stroke(.quaternary, lineWidth: 1)
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("Messages, opening \(landingRow)")
		.accessibilityIdentifier("learn.fairPoint.inbox")
		.task {
			await play()
		}
	}

	/// Scrolls so the landing row is second from the bottom
	private var landingOffset: CGFloat {
		let index = rows.firstIndex { $0.id == landingRow } ?? 0
		return rowHeight * CGFloat(max(0, index - (visibleRows - 2)))
	}

	private func play() async {
		if reduceMotion {
			hasLanded = true
			isHighlighted = true
			try? await Task.sleep(for: .seconds(0.8))
		} else {
			// A moment to see it's an inbox before it moves
			try? await Task.sleep(for: .seconds(0.7))
			guard !Task.isCancelled else { return }
			withAnimation(.timingCurve(0.3, 0.1, 0.2, 1, duration: 2.2)) {
				hasLanded = true
			}
			try? await Task.sleep(for: .seconds(2.4))
			guard !Task.isCancelled else { return }
			withAnimation(.easeOut(duration: 0.25)) {
				isHighlighted = true
			}
			try? await Task.sleep(for: .seconds(0.8))
		}

		guard !Task.isCancelled else { return }
		onOpen()
	}
}

/// One conversation in the inbox
private struct InboxRowView: View {
	let row: InboxRow
	let isHighlighted: Bool

	var body: some View {
		HStack(spacing: 12) {
			ChatAvatar(name: row.name, size: 44)

			VStack(alignment: .leading, spacing: 2) {
				HStack {
					Text(row.name)
						.font(.headline)
						.lineLimit(1)

					Spacer(minLength: 4)

					Text(row.time)
						.font(.subheadline)
						.foregroundStyle(.secondary)

					Image(systemName: "chevron.right")
						.font(.footnote.weight(.semibold))
						.foregroundStyle(.tertiary)
				}

				Text(row.preview)
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.lineLimit(2)
			}
		}
		.padding(.horizontal, 8)
		.frame(maxHeight: .infinity)
		.background(isHighlighted ? Color(.systemGray4) : Color.clear, in: .rect(cornerRadius: 12))
		.overlay(alignment: .bottom) {
			Divider()
				.padding(.leading, 64)
		}
	}
}
