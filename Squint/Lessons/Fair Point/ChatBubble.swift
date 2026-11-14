//
//  ChatBubble.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

/// A message bubble, like Messages: blue on the right for you, grey on the left for them
struct ChatBubble: View {
	let message: ChatMessage
	/// Only the last of a run of messages from one person has a tail
	let hasTail: Bool
	var outline: Color?

	private var isYou: Bool {
		message.sender == .you
	}

	var body: some View {
		Text(message.text)
			.foregroundStyle(isYou ? Color.white : Color.primary)
			.padding(.vertical, 8)
			.padding(.leading, isYou ? 12 : 12 + BubbleShape.tailWidth)
			.padding(.trailing, isYou ? 12 + BubbleShape.tailWidth : 12)
			.background(isYou ? Color.blue : Color(.systemGray5), in: shape)
			.overlay {
				if let outline {
					shape.stroke(outline, lineWidth: 2)
				}
			}
	}

	private var shape: BubbleShape {
		BubbleShape(isYou: isYou, hasTail: hasTail)
	}

	/// The same bubble, outlined in a colour
	func outlined(_ color: Color?) -> ChatBubble {
		var copy = self
		copy.outline = color
		return copy
	}
}

/// A rounded bubble with room for a tail at the bottom corner on the sender's side
nonisolated struct BubbleShape: Shape {
	static let tailWidth: CGFloat = 6

	let isYou: Bool
	let hasTail: Bool

	func path(in rect: CGRect) -> Path {
		let tail = Self.tailWidth
		let body = CGRect(
			x: isYou ? rect.minX : rect.minX + tail,
			y: rect.minY,
			width: max(0, rect.width - tail),
			height: rect.height
		)
		let bubble = Path(roundedRect: body, cornerRadius: min(18, body.height / 2), style: .continuous)

		guard hasTail else {
			return bubble
		}

		return bubble.union(tailPath(in: rect))
	}

	/// Drawn for your side, and mirrored for theirs
	private func tailPath(in rect: CGRect) -> Path {
		let edge = rect.maxX - Self.tailWidth
		let bottom = rect.maxY

		func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
			CGPoint(x: isYou ? x : rect.minX + rect.maxX - x, y: y)
		}

		var path = Path()
		path.move(to: point(edge, bottom - 16))
		path.addQuadCurve(to: point(rect.maxX, bottom), control: point(edge, bottom - 3))
		path.addQuadCurve(to: point(edge - 11, bottom - 2), control: point(edge - 3, bottom))
		path.closeSubpath()
		return path
	}
}
