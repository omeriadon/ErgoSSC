//
//  BiggerPictureChart.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Charts
import SwiftUI

/// The lesson's bar chart. Bars before `visibleFrom` aren't drawn at all, so moving it zooms in or out.
struct BiggerPictureChart: View {
	let points: [ChartPoint]
	let measure: String
	let visibleFrom: Int
	/// Drawn in the lesson's colour. The rest are faint.
	var highlighted: Set<Int> = []
	/// Page 2: bars before it are dimmed right down
	var countingFrom: Int?
	var usual: Double?
	var comparison: [ChartPoint]?
	var note: (year: Int, text: String)?
	/// Page 2: dragging picks a year
	var onPick: ((Int) -> Void)?
	var height: CGFloat = 200

	private let tint = Lesson.biggerPicture.tint

	private var visible: [ChartPoint] {
		points.filter { $0.year >= visibleFrom }
	}

	/// Fixed, so bars keep their heights as years come and go
	private var top: Double {
		let values = points.map(\.value) + (comparison ?? []).map(\.value)
		return (values.max() ?? 1) * 1.2
	}

	var body: some View {
		Chart {
			bars
			usualLine
			comparisonLine
		}
		.chartYScale(domain: 0 ... top)
		.chartXAxis {
			AxisMarks { value in
				AxisValueLabel {
					if let label = value.as(String.self) {
						Text("’\(label.suffix(2))")
					}
				}
			}
		}
		.chartOverlay { proxy in
			GeometryReader { geometry in
				Rectangle()
					.fill(.clear)
					.contentShape(.rect)
					.gesture(drag(proxy: proxy, geometry: geometry))
					.allowsHitTesting(onPick != nil)
			}
		}
		.frame(height: height)
	}

	// MARK: - Marks

	@ChartContentBuilder
	private var bars: some ChartContent {
		ForEach(visible) { point in
			BarMark(
				x: .value("Year", point.label),
				y: .value(measure, point.value)
			)
			.foregroundStyle(color(for: point))
			.cornerRadius(3)
			.annotation(position: .top, spacing: 4) {
				if let note, note.year == point.year {
					Text(note.text)
						.font(.caption2.weight(.semibold))
						.foregroundStyle(tint)
						.fixedSize()
				}
			}
		}
	}

	@ChartContentBuilder
	private var usualLine: some ChartContent {
		if let usual {
			RuleMark(y: .value("Usual", usual))
				.foregroundStyle(.secondary)
				.lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
				.annotation(position: .top, alignment: .leading) {
					Text("Usual")
						.font(.caption2)
						.foregroundStyle(.secondary)
				}
		}
	}

	@ChartContentBuilder
	private var comparisonLine: some ChartContent {
		if let comparison {
			ForEach(comparison.filter { $0.year >= visibleFrom }) { point in
				LineMark(
					x: .value("Year", point.label),
					y: .value("Roads without cameras", point.value),
					series: .value("Series", "Roads without cameras")
				)
				.foregroundStyle(.primary.opacity(0.6))
				.lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 3]))
				.symbol(.circle)
				.symbolSize(18)
			}
		}
	}

	private func color(for point: ChartPoint) -> Color {
		if let countingFrom, point.year < countingFrom {
			return .secondary.opacity(0.15)
		}
		return highlighted.contains(point.year) ? tint : tint.opacity(0.3)
	}

	// MARK: - Picking a year

	private func drag(proxy: ChartProxy, geometry: GeometryProxy) -> some Gesture {
		DragGesture(minimumDistance: 0)
			.onChanged { value in
				guard let onPick, let plotFrame = proxy.plotFrame else { return }
				let x = value.location.x - geometry[plotFrame].origin.x
				if let label: String = proxy.value(atX: x), let year = Int(label) {
					onPick(year)
				}
			}
	}
}

/// The article the chart sits in, like a page of a local paper
struct BiggerPictureArticle<Content: View>: View {
	let headline: String
	@ViewBuilder var chart: Content

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(BiggerPicture.paper.uppercased())
				.font(.caption2.weight(.heavy))
				.tracking(1.5)
				.foregroundStyle(.secondary)

			Text(headline)
				.font(.title2.bold())
				.fontDesign(.serif)
				.fixedSize(horizontal: false, vertical: true)
				.contentTransition(.numericText())

			Divider()

			chart

			Text("Crashes on Station Road, per year")
				.font(.caption)
				.foregroundStyle(.secondary)
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(.background.secondary, in: .rect(cornerRadius: 22))
	}
}

/// The full-width button that moves the lesson on
struct BiggerPictureContinueButton: View {
	let identifier: String
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Text("Continue")
				.font(.headline)
				.frame(maxWidth: .infinity)
		}
		.buttonStyle(.glassProminent)
		.controlSize(.large)
		.accessibilityIdentifier("learn.biggerPicture.continue.\(identifier)")
	}
}
