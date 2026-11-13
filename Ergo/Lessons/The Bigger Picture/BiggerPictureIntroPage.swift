//
//  BiggerPictureIntroPage.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Page 1: two bars that look convincing, then every year
struct BiggerPictureIntroPage: View {
	@Default(.biggerPictureState) private var state

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	/// Local, so each step of the zoom animates whatever the save does
	@State private var visibleFrom: Int
	@State private var showsUsual: Bool
	@State private var showsNote: Bool
	@State private var showsAfter: Bool

	init() {
		let zoomedOut = Defaults[.biggerPictureState].zoomedOut
		_visibleFrom = State(initialValue: zoomedOut ? BiggerPicture.firstYear : BiggerPicture.spikeYear)
		_showsUsual = State(initialValue: zoomedOut)
		_showsNote = State(initialValue: zoomedOut)
		_showsAfter = State(initialValue: zoomedOut)
	}

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				VStack(alignment: .leading, spacing: 28) {
					article

					below
				}
				.padding()
			}
			.onChange(of: showsAfter) { _, shows in
				guard shows else { return }
				Task {
					try? await Task.sleep(for: .seconds(0.8))
					withAnimation(reduceMotion ? nil : .smooth(duration: 0.8)) {
						proxy.scrollTo("after", anchor: .top)
					}
				}
			}
		}
		.navigationTitle(lessonTitle(.biggerPicture, Lesson.biggerPicture.pageTitle))
	}

	private var article: some View {
		BiggerPictureArticle(headline: BiggerPicture.headline) {
			BiggerPictureChart(
				points: BiggerPicture.crashes,
				measure: BiggerPicture.measure,
				visibleFrom: visibleFrom,
				highlighted: [BiggerPicture.spikeYear, BiggerPicture.lastYear],
				usual: showsUsual ? BiggerPicture.usual : nil,
				note: showsNote ? (year: BiggerPicture.spikeYear, text: BiggerPicture.spikeNote) : nil
			)
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(accessibilityDescription)
	}

	@ViewBuilder
	private var below: some View {
		if !state.zoomedOut {
			convincing
				.transition(.opacity)
		} else if showsAfter {
			BiggerPictureTerms {
				state.page = .deeperLook
			}
			.id("after")
			.transition(.opacity.combined(with: .offset(y: 24)))
		}
	}

	private var convincing: some View {
		VStack(spacing: 20) {
			Text("Pretty convincing, right?")
				.font(.title3)
				.multilineTextAlignment(.center)

			Button(action: zoomOut) {
				Label("Zoom out…", systemImage: "arrow.up.left.and.arrow.down.right")
					.font(.headline)
			}
			.buttonStyle(.glassProminent)
			.buttonBorderShape(.roundedRectangle(radius: 12))
			.controlSize(.large)
			.accessibilityIdentifier("learn.biggerPicture.zoomOut")
		}
		.frame(maxWidth: .infinity)
	}

	private var accessibilityDescription: String {
		if visibleFrom == BiggerPicture.spikeYear {
			return "\(BiggerPicture.headline). Chart: 40 crashes in 2023, 20 in 2024."
		}
		let values = BiggerPicture.crashes.map { "\($0.year): \(Int($0.value))" }.joined(separator: ", ")
		return "\(BiggerPicture.headline). Chart of every year: \(values)."
	}

	// MARK: - The zoom

	/// The two bars make room as the earlier years come in one at a time, then the usual line, then the note
	private func zoomOut() {
		withAnimation(.smooth(duration: 0.4)) {
			state.zoomedOut = true
		}

		if reduceMotion {
			withAnimation(.easeInOut(duration: 0.4)) {
				visibleFrom = BiggerPicture.firstYear
				showsUsual = true
				showsNote = true
				showsAfter = true
			}
			return
		}

		Task {
			// Let the button go first
			try? await Task.sleep(for: .seconds(0.5))

			for year in stride(from: BiggerPicture.spikeYear - 1, through: BiggerPicture.firstYear, by: -1) {
				withAnimation(.smooth(duration: 0.5)) {
					visibleFrom = year
				}
				try? await Task.sleep(for: .seconds(0.24))
			}

			try? await Task.sleep(for: .seconds(0.7))
			withAnimation(.easeInOut(duration: 0.6)) {
				showsUsual = true
			}

			try? await Task.sleep(for: .seconds(1))
			withAnimation(.smooth(duration: 0.5)) {
				showsNote = true
			}

			try? await Task.sleep(for: .seconds(1.2))
			withAnimation(.smooth(duration: 0.6)) {
				showsAfter = true
			}
		}
	}
}

/// What zooming out showed, the two terms, and the way on
private struct BiggerPictureTerms: View {
	let onContinue: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text(BiggerPicture.zoomedOutLine)
				.font(.title3)
				.fixedSize(horizontal: false, vertical: true)

			Text("Two terms for what just happened:")
				.font(.headline)
				.padding(.top, 8)

			VStack(spacing: 10) {
				BiggerPictureTermRow(
					name: "Cherry-picking",
					symbol: "scissors",
					definition: "Choosing where to start counting, so the numbers tell your story."
				)
				BiggerPictureTermRow(
					name: "Back to normal",
					symbol: "arrow.uturn.down",
					definition: "After an unusually bad (or good) stretch, things usually drift back to normal on their own, even if nothing changes."
				)
			}

			BiggerPictureContinueButton(identifier: "terms", action: onContinue)
				.padding(.top, 8)
		}
	}
}

private struct BiggerPictureTermRow: View {
	let name: String
	let symbol: String
	let definition: String

	private let tint = Lesson.biggerPicture.tint

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
