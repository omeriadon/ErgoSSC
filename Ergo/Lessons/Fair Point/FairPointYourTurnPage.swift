//
//  FairPointYourTurnPage.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

/// Page 3: scribble over Leo's unfair messages
struct FairPointYourTurnPage: View {
	@Binding var state: FairPointState

	/// Leo's bubbles, in the scribble area's coordinate space
	@State private var frames: [String: CGRect] = [:]
	@State private var ink: [CGPoint] = []
	@State private var inkOpacity = 1.0
	@State private var isDrawing = false
	@State private var shown: String?

	private var hasFoundAll: Bool {
		FairPoint.leo.notedMessages.allSatisfy { $0.isFair || state.scribbledLeo.contains($0.id) }
	}

	var body: some View {
		// Only scrolls when it doesn't fit, so the scribble isn't fighting a scroll
		ViewThatFits(in: .vertical) {
			content
			ScrollView {
				content
			}
		}
		.frame(maxHeight: .infinity, alignment: .top)
		.navigationTitle(lessonTitle(.fairPoint, "Your turn!"))
	}

	private var content: some View {
		VStack(alignment: .leading, spacing: 20) {
			Text("Here's another convo you might have. Now scribble over any message that doesn't seem fair.")

			scribbleArea

			// Always laid out, so the page doesn't switch to scrolling when it appears
			Button("Continue") {
				state.page = .summary
			}
			.buttonStyle(.glassProminent)
			.buttonBorderShape(.roundedRectangle(radius: 12))
			.frame(maxWidth: .infinity)
			.opacity(hasFoundAll ? 1 : 0)
			.disabled(!hasFoundAll)
			.accessibilityHidden(!hasFoundAll)
			.accessibilityIdentifier("learn.fairPoint.continue")
		}
		.padding()
	}

	private var scribbleArea: some View {
		ChatConversation(thread: FairPoint.leo) { message, bubble in
			bubbleView(message, bubble)
		}
		.overlay {
			InkStroke(points: ink)
				.opacity(inkOpacity)
				.allowsHitTesting(false)
		}
		.contentShape(Rectangle())
		.gesture(scribble)
		.coordinateSpace(.named("fairPoint.scribble"))
	}

	@ViewBuilder
	private func bubbleView(_ message: ChatMessage, _ bubble: ChatBubble) -> some View {
		if message.note == nil {
			bubble
		} else {
			LeoBubble(
				message: message,
				bubble: bubble,
				isScribbled: state.scribbledLeo.contains(message.id),
				isShowingNote: fairPointNoteBinding(message.id, shown: $shown),
				onFrame: { frames[message.id] = $0 },
				onScribble: { mark([message.id]) }
			)
		}
	}

	private var scribble: some Gesture {
		DragGesture(minimumDistance: 0, coordinateSpace: .named("fairPoint.scribble"))
			.onChanged { value in
				if isDrawing {
					ink.append(value.location)
				} else {
					isDrawing = true
					ink = [value.location]
					inkOpacity = 1
				}
			}
			.onEnded { _ in
				isDrawing = false
				finishStroke()
			}
	}

	private func finishStroke() {
		// A tap counts as a scribble too, and shows the popover again on one that's already marked
		mark(Scribble.crossed(ink, frames: frames, order: FairPoint.leo.notedMessages.map(\.id)))

		withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
			inkOpacity = 0
		}
	}

	/// Marks bubbles as scribbled, and shows the popover of the first new one
	private func mark(_ ids: [String]) {
		guard !ids.isEmpty else { return }
		let new = ids.filter { !state.scribbledLeo.contains($0) }
		state.scribbledLeo.formUnion(ids)
		shown = new.first ?? ids.first
	}
}

/// One of Leo's messages: caught when it's unfair, a gentle tick when it's fair
private struct LeoBubble: View {
	let message: ChatMessage
	let bubble: ChatBubble
	let isScribbled: Bool
	@Binding var isShowingNote: Bool
	let onFrame: (CGRect) -> Void
	let onScribble: () -> Void

	private var tint: Color? {
		guard isScribbled else { return nil }
		return message.isFair ? Color.green : Color.red
	}

	var body: some View {
		bubble.outlined(tint)
			.onGeometryChange(for: CGRect.self) { proxy in
				proxy.frame(in: .named("fairPoint.scribble"))
			} action: { frame in
				onFrame(frame)
			}
			.fairPointNote(message.note, isPresented: $isShowingNote)
			.accessibilityElement(children: .ignore)
			.accessibilityLabel("Leo: \(message.text)")
			.accessibilityValue(value)
			.accessibilityAction(named: "Scribble over", onScribble)
			.accessibilityIdentifier("learn.fairPoint.\(message.id)")
			// Beside the bubble but outside its layout, so the bubble keeps its width when it appears
			.overlay(alignment: .trailing) {
				if let tint {
					Image(systemName: message.isFair ? "checkmark.circle.fill" : "xmark.circle.fill")
						.foregroundStyle(tint)
						.alignmentGuide(.trailing) { $0[.leading] - 6 }
						.accessibilityHidden(true)
				}
			}
	}

	private var value: String {
		guard isScribbled else { return "" }
		return message.isFair ? "Fair" : "Caught"
	}
}

/// The ink as it's drawn, like a highlighter. Curved through the midpoints, so it's smooth however fast the finger moves.
private struct InkStroke: View {
	let points: [CGPoint]

	var body: some View {
		Path { path in
			guard let first = points.first else { return }
			path.move(to: first)
			// A tap still leaves a dot
			path.addLine(to: first)
			for (point, next) in zip(points, points.dropFirst()) {
				path.addQuadCurve(to: CGPoint(x: (point.x + next.x) / 2, y: (point.y + next.y) / 2), control: point)
			}
			if let last = points.last {
				path.addLine(to: last)
			}
		}
		.stroke(
			Color.accentColor.opacity(0.55),
			style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round)
		)
	}
}

/// Matching a stroke to bubbles by their frames, not their words
private nonisolated enum Scribble {
	/// The ids whose frames the stroke crosses, in conversation order. A frame reaches a little past the bubble's sides, so a stroke that only just misses still counts.
	static func crossed(_ points: [CGPoint], frames: [String: CGRect], order: [String]) -> [String] {
		let samples = densified(points)
		return order.filter { id in
			guard let frame = frames[id]?.insetBy(dx: -12, dy: -1) else { return false }
			return samples.contains { frame.contains($0) }
		}
	}

	/// Fills in a point every two points along the stroke, so a fast flick can't skip a bubble
	private static func densified(_ points: [CGPoint]) -> [CGPoint] {
		guard var previous = points.first else { return [] }
		var result = [previous]

		for point in points.dropFirst() {
			let distance = hypot(point.x - previous.x, point.y - previous.y)
			let steps = max(1, Int(distance / 2))

			for step in 1 ... steps {
				let t = CGFloat(step) / CGFloat(steps)
				result.append(CGPoint(
					x: previous.x + (point.x - previous.x) * t,
					y: previous.y + (point.y - previous.y) * t
				))
			}

			previous = point
		}

		return result
	}
}
