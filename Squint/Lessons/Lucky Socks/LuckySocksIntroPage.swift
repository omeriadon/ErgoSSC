//
//  LuckySocksIntroPage.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Page 1: the four games Jess remembers, then the whole season sorted into the four boxes
struct LuckySocksIntroPage: View {
	@Default(.luckySocksState) private var state

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	@Namespace private var cards

	/// Local, so each step of the reveal animates whatever the save does
	@State private var shown: Set<Int>
	@State private var isSorted: Bool
	@State private var showsCounts: Bool
	@State private var showsAfter: Bool
	@State private var showsTerms: Bool

	init() {
		let revealed = Defaults[.luckySocksState].showsSeason
		_shown = State(initialValue: revealed ? Set(LuckySocks.season.map(\.id)) : LuckySocks.remembered)
		_isSorted = State(initialValue: revealed)
		_showsCounts = State(initialValue: revealed)
		_showsAfter = State(initialValue: revealed)
		_showsTerms = State(initialValue: revealed)
	}

	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				VStack(alignment: .leading, spacing: 40) {
					LuckySocksMessage(id: "jess.socks", text: LuckySocks.socksMessage)

					season

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
			.onChange(of: showsTerms) { _, shows in
				guard shows else { return }
				Task {
					try? await Task.sleep(for: .seconds(0.6))
					withAnimation(reduceMotion ? nil : .smooth(duration: 0.8)) {
						proxy.scrollTo("terms", anchor: .bottom)
					}
				}
			}
		}
		.navigationTitle(lessonTitle(.luckySocks, Lesson.luckySocks.title))
	}

	// MARK: - The season

	private var season: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(state.showsSeason ? "The whole season" : "The games Jess remembers")
				.font(.caption.weight(.semibold))
				.foregroundStyle(.secondary)
				.textCase(.uppercase)
				.contentTransition(.opacity)

			if isSorted {
				sorted
			} else {
				inOrder
			}
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(seasonDescription)
	}

	/// Every game in the order it was played, with the ones she doesn't remember left as gaps
	private var inOrder: some View {
		VStack(alignment: .leading, spacing: 8) {
			ForEach(0 ..< 2) { row in
				HStack(spacing: 8) {
					ForEach(LuckySocks.season[(row * 6) ..< (row * 6 + 6)]) { game in
						card(game)
							.opacity(shown.contains(game.id) ? 1 : 0)
					}
				}
			}
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 12)
	}

	/// The same games, each in its box
	private var sorted: some View {
		FourBoxGrid(labels: LuckySocks.seasonLabels) { box in
			VStack(spacing: 6) {
				HStack(spacing: 4) {
					ForEach(LuckySocks.season.filter { $0.box == box }) { game in
						card(game)
					}
				}

				if showsCounts {
					Text("\(LuckySocks.seasonCounts[box])")
						.font(.headline.monospacedDigit())
						.transition(.opacity)
				}
			}
			.frame(maxWidth: .infinity, minHeight: 64)
			.padding(.vertical, 8)
			.background {
				FourBoxBackground(isLit: box == .both)
			}
		}
	}

	private func card(_ game: LuckySocksGame) -> some View {
		LuckySocksGameCard(game: game)
			.matchedGeometryEffect(id: game.id, in: cards)
	}

	// MARK: - Under it

	@ViewBuilder
	private var below: some View {
		if !state.showsSeason {
			Button(action: reveal) {
				Label("Show the whole season", systemImage: "calendar")
					.font(.headline)
			}
			.buttonStyle(.glassProminent)
			.buttonBorderShape(.roundedRectangle(radius: 12))
			.controlSize(.large)
			.frame(maxWidth: .infinity)
			.transition(.opacity)
			.accessibilityIdentifier("learn.luckySocks.showSeason")
		} else if showsAfter {
			VStack(alignment: .leading, spacing: 16) {
				LuckySocksResult()
					.id("after")

				if showsTerms {
					LuckySocksTerms {
						state.page = .deeperLook
					}
					.id("terms")
					.padding(.top, 8)
					.transition(.opacity.combined(with: .offset(y: 24)))
				}
			}
			.transition(.opacity.combined(with: .offset(y: 24)))
		}
	}

	private var seasonDescription: String {
		guard state.showsSeason else {
			return "The games Jess remembers: four wins, all in her lucky socks."
		}
		let counts = LuckySocks.seasonCounts
		return "The whole season of \(LuckySocks.season.count) games. With socks: won \(counts.both), lost \(counts.firstOnly). Without socks: won \(counts.secondOnly), lost \(counts.neither)."
	}

	// MARK: - The reveal

	/// The rest of the season fades in a game at a time, then every game flies into its box, then the counts
	private func reveal() {
		withAnimation(.smooth(duration: 0.4)) {
			state.showsSeason = true
		}

		let everyGame = Set(LuckySocks.season.map(\.id))

		if reduceMotion {
			withAnimation(.easeInOut(duration: 0.4)) {
				shown = everyGame
				isSorted = true
				showsCounts = true
				showsAfter = true
				showsTerms = true
			}
			return
		}

		Task {
			// Let the button go first
			try? await Task.sleep(for: .seconds(0.5))

			for game in LuckySocks.season where !shown.contains(game.id) {
				withAnimation(.smooth(duration: 0.35)) {
					_ = shown.insert(game.id)
				}
				try? await Task.sleep(for: .seconds(0.14))
			}

			// A moment with the whole season in order before it's sorted
			try? await Task.sleep(for: .seconds(1.2))
			withAnimation(.smooth(duration: 0.9)) {
				isSorted = true
			}

			try? await Task.sleep(for: .seconds(1.3))
			withAnimation(.smooth(duration: 0.5)) {
				showsCounts = true
			}

			try? await Task.sleep(for: .seconds(1.2))
			withAnimation(.smooth(duration: 0.6)) {
				showsAfter = true
			}

			// Time to read what the season showed before the terms for it
			try? await Task.sleep(for: .seconds(2.2))
			withAnimation(.smooth(duration: 0.6)) {
				showsTerms = true
			}
		}
	}
}

/// What the season showed
private struct LuckySocksResult: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			FourBoxComparison(labels: LuckySocks.seasonLabels, counts: LuckySocks.seasonCounts)

			Text(LuckySocks.seasonLine)
				.font(.title3)
				.fixedSize(horizontal: false, vertical: true)
		}
	}
}

/// The two terms for it, and the way on
private struct LuckySocksTerms: View {
	let onContinue: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Two ideas for what just happened:")
				.font(.headline)

			VStack(spacing: 10) {
				LuckySocksTermRow(
					name: "Confirmation bias",
					symbol: "eye",
					definition: "Noticing and remembering what fits what you already believe, and missing what doesn't."
				)
				LuckySocksTermRow(
					name: "Count the misses",
					symbol: "square.grid.2x2",
					definition: "To check if two things really go together, count all four boxes, not just the times they both happened."
				)
			}

			LuckySocksContinueButton(identifier: "terms", action: onContinue)
				.padding(.top, 8)
		}
	}
}
