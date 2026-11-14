//
//  WelcomeSheet.swift
//  Squint
//
//  Created by Adon Omeri on 14/11/2026.
//

import Defaults
import SwiftUI

/// The first time the app opens: what it's for, and where to start
struct WelcomeSheet: View {
	@Environment(NavigationManager.self)
	private var navigation

	var body: some View {
		VStack(spacing: 0) {
			Spacer(minLength: 24)

			header

			Spacer(minLength: 32)

			VStack(alignment: .leading, spacing: 24) {
				WelcomeRow(
					symbol: "text.magnifyingglass",
					tint: .orange,
					title: "Start with a lesson",
					detail: "Each takes a few minutes. Try it on posts, chats and charts, and see what holds up."
				)
				WelcomeRow(
					symbol: "books.vertical",
					tint: .blue,
					title: "Read further in the Library",
					detail: "Every fallacy and bias the lessons mention, and many more, each with examples."
				)
			}
			.padding(.horizontal, 8)

			Spacer(minLength: 32)

			Button {
				navigation.reveal(.learn)
			} label: {
				Text("Start Learning")
					.font(.headline)
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.glassProminent)
			.buttonBorderShape(.roundedRectangle(radius: 12))
			.controlSize(.large)
			.accessibilityIdentifier("welcome.start")
		}
		.padding(24)
		.onDisappear {
			// However it was closed, it was seen
			Defaults[.hasSeenWelcome] = true
		}
	}

	private var header: some View {
		VStack(spacing: 16) {
			SquintIcon(size: 300)

			Text("Welcome to \(Bundle.main.appName)")
				.font(.largeTitle.bold())

			Text("See what something is actually claiming, and whether anything holds it up.")
				.font(.title3)
				.foregroundStyle(.secondary)
		}
		.multilineTextAlignment(.center)
		.fixedSize(horizontal: false, vertical: true)
	}
}

/// One thing to do, with its symbol
private struct WelcomeRow: View {
	let symbol: String
	let tint: Color
	let title: String
	let detail: String

	var body: some View {
		HStack(alignment: .top, spacing: 16) {
			Image(systemName: symbol)
				.font(.title2)
				.foregroundStyle(tint)
				.frame(width: 36)
				.accessibilityHidden(true)

			VStack(alignment: .leading, spacing: 4) {
				Text(title)
					.font(.headline)

				Text(detail)
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.fixedSize(horizontal: false, vertical: true)
			}
		}
		.accessibilityElement(children: .combine)
	}
}
