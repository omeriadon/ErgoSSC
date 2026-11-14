//
//  BiggerPictureContent.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Foundation

/// One year's bar
nonisolated struct ChartPoint: Identifiable, Hashable, Sendable {
	let year: Int
	let value: Double

	var id: Int {
		year
	}

	/// The chart's x value. Years are categories, so every bar is the same width.
	var label: String {
		String(year)
	}
}

/// A label on one year's bar
nonisolated struct ChartMarker: Hashable, Sendable {
	let year: Int
	let text: String
}

/// A headline on page 3, the window its chart picked, and whether that's fair
nonisolated struct BiggerPictureQuizItem: Identifiable, Hashable, Sendable {
	let id: Int
	let headline: String
	/// What the bars count, for VoiceOver and the axis
	let measure: String
	let points: [ChartPoint]
	/// The first year the headline counts from
	let pickedFrom: Int
	/// The first year its chart shows before it's answered. Usually where the headline counts from, so a cherry-picked one looks fair.
	let shownFrom: Int
	let isFair: Bool
	/// On the year the headline started from, once zoomed out
	let pickNote: String?
	/// Something the headline mentions, marked on its year from the start, like when a new coach arrived
	var marker: ChartMarker?
	let explanation: String

	/// What a normal year looks like, without the one the headline started from
	var usual: Double {
		let others = points.filter { $0.year != pickedFrom }
		return others.map(\.value).reduce(0, +) / Double(others.count)
	}
}

/// Everything lesson 3 says. Every answer is authored here, and every number is computed from the data.
nonisolated enum BiggerPicture {
	static let paper = "The Northside Herald"

	static let headline = "Speed cameras cut crashes on Station Road by half"

	static let measure = "Crashes"

	static let firstYear = 2015
	static let lastYear = 2024
	/// The worst year, after which the cameras went in
	static let spikeYear = 2023

	static let crashes = points([21, 19, 22, 20, 21, 18, 18, 23, 40, 20])

	/// Similar roads without cameras
	static let otherRoads = points([22, 20, 21, 21, 20, 19, 19, 22, 38, 24])

	/// The average before the spike: what a normal year looks like
	static var usual: Double {
		let before = crashes.filter { $0.year < spikeYear }
		return before.map(\.value).reduce(0, +) / Double(before.count)
	}

	static let spikeNote = "Worst year"

	static let zoomedOutLine = "Zoomed out, we can see 2023 was a one-off. The cameras focussed in to 23-24, because it looks much bigger than it actually is. Most years are about \(Int(usual.rounded())) anyway."

	static var comparisonLine: String {
		let before = Int(value(otherRoads, spikeYear))
		let after = Int(value(otherRoads, lastYear))
		return "Roads without cameras dropped too, from \(before) to \(after). So the cameras might still help, just less than the headline says."
	}

	static let takeaway = "Before trusting a number, ask where the counting started, and what it's being compared to."

	/// Page 2's headline for counting from a year to the last one
	static func headline(from year: Int) -> String {
		let start = value(crashes, year)
		let change = (value(crashes, lastYear) - start) / start
		let percent = Int((abs(change) * 100).rounded())

		if change <= -0.45 {
			return "Crashes halved since \(year)!"
		} else if percent < 3 {
			return "Crashes about the same as \(year)"
		} else if change < 0 {
			return "Crashes down \(percent)% since \(year)"
		} else {
			return "Crashes up \(percent)% since \(year)"
		}
	}

	static let quiz: [BiggerPictureQuizItem] = [
		BiggerPictureQuizItem(
			id: 0,
			headline: "House prices up 30% since 2020!",
			measure: "Average price ($k)",
			points: points([610, 640, 655, 630, 620, 520, 600, 650, 660, 676]),
			pickedFrom: 2020,
			shownFrom: 2020,
			isFair: false,
			pickNote: "A dip",
			explanation: "Yes, it does look like a fair picture. But zoom out, and 2020 was a dip: over ten years, prices have only gone up about 10%."
		),
		BiggerPictureQuizItem(
			id: 1,
			headline: "Library visits have grown every year since 2015.",
			measure: "Visits (thousands)",
			points: points([40, 43, 46, 48, 51, 53, 56, 58, 61, 64]),
			pickedFrom: 2015,
			shownFrom: 2015,
			isFair: true,
			pickNote: nil,
			explanation: "This one's fair. It shows the whole picture, and the climb is steady all the way."
		),
		BiggerPictureQuizItem(
			id: 2,
			headline: "Goals doubled after the new coach arrived!",
			measure: "Goals",
			points: points([48, 52, 50, 47, 51, 49, 53, 50, 24, 49]),
			pickedFrom: 2023,
			shownFrom: firstYear,
			isFair: false,
			pickNote: "Worst season",
			marker: ChartMarker(year: 2024, text: "New coach"),
			explanation: "Last season was their worst in a decade. Most seasons they score about 50, so this is mostly back to normal."
		),
	]

	/// The line under the quiz score when the model on the device can't write one (`LessonScoreLine`)
	static func scoreLine(for score: Int) -> String {
		switch score {
			case 3: "All three. You're already asking where the counting started."
			case 2: "Two of three. The one you missed is worth another look."
			default: "These charts are made to look convincing. Zooming out is the habit to build."
		}
	}

	static func value(_ points: [ChartPoint], _ year: Int) -> Double {
		points.first { $0.year == year }?.value ?? 0
	}

	/// Ten values, one a year from 2015
	private static func points(_ values: [Double]) -> [ChartPoint] {
		values.enumerated().map { ChartPoint(year: firstYear + $0.offset, value: $0.element) }
	}
}
