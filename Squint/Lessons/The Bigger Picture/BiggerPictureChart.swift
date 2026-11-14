//
//  BiggerPictureChart.swift
//  Squint
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
	var usual: Double?
	var comparison: [ChartPoint]?
	var note: (year: Int, text: String)?
	/// A dashed line just before its year, shown all along, unlike the note
	var marker: ChartMarker?
	/// Bars from here on are grown to their value. Earlier visible ones are drawn flat, so a bar can grow in after its year arrives.
	var grownFrom: Int?
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
		.chartOverlay { proxy in
			GeometryReader { geometry in
				markerLine(proxy, in: geometry)
			}
		}
		.chartXAxis {
			AxisMarks { value in
				AxisValueLabel {
					if let label = value.as(String.self) {
						Text("’\(label.suffix(2))")
					}
				}
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
				y: .value(measure, point.year >= (grownFrom ?? visibleFrom) ? point.value : 0)
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

	/// Between the marker's year and the one before. Years are categories, which a rule mark can only sit in the middle of,
	/// so it's drawn over the chart halfway between the two bars.
	@ViewBuilder
	private func markerLine(_ proxy: ChartProxy, in geometry: GeometryProxy) -> some View {
		if let marker, let plotFrame = proxy.plotFrame,
		   let before = proxy.position(forX: String(marker.year - 1)),
		   let year = proxy.position(forX: String(marker.year))
		{
			let plot = geometry[plotFrame]
			let x = plot.minX + (before + year) / 2

			Path { path in
				path.move(to: CGPoint(x: x, y: plot.minY + 14))
				path.addLine(to: CGPoint(x: x, y: plot.maxY))
			}
			.stroke(.secondary, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))

			Text(marker.text)
				.font(.caption2.weight(.semibold))
				.foregroundStyle(.secondary)
				.fixedSize()
				.position(x: x, y: plot.minY + 5)
		}
	}

	private func color(for point: ChartPoint) -> Color {
		highlighted.contains(point.year) ? tint : tint.opacity(0.3)
	}
}

/// The article the chart sits in, like a page of a local paper
struct BiggerPictureArticle<Content: View>: View {
	let headline: String
	/// Page 2 rewrites the headline as you zoom, so it keeps two lines' room whatever it says
	var reservesTwoLines = false
	@ViewBuilder var chart: Content

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(BiggerPicture.paper.uppercased())
				.font(.caption2.weight(.heavy))
				.tracking(1.5)
				.foregroundStyle(.secondary)

			Text(headline)
				.font(.system(.title2, design: .serif, weight: .bold))
				.lineLimit(reservesTwoLines ? 2 : 4, reservesSpace: reservesTwoLines)
				.fixedSize(horizontal: false, vertical: true)
				.contentTransition(.numericText())

			Divider()

			chart

			Text("Crashes on Station Road, per year")
				.font(.caption)
				.foregroundStyle(.secondary)
		}
		.fontDesign(.serif)
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
		.buttonBorderShape(.roundedRectangle(radius: 12))
		.controlSize(.large)
		.accessibilityIdentifier("learn.biggerPicture.continue.\(identifier)")
	}
}
