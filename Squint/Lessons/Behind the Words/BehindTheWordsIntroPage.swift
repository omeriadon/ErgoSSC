//
//  BehindTheWordsIntroPage.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Page 1: the reply as it looks, then the three terms
struct BehindTheWordsIntroPage: View {
	@Default(.behindTheWordsState) private var state

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 28) {
				BehindTheWordsForumReply {
					Text(BehindTheWords.passage)
						.font(.body)
						.fixedSize(horizontal: false, vertical: true)
				}

				below
			}
			.padding()
			.animation(reduceMotion ? .easeInOut(duration: 0.2) : .smooth(duration: 0.5), value: state.showsTerms)
		}
		.navigationTitle(lessonTitle(.behindTheWords, Lesson.behindTheWords.title))
	}

	@ViewBuilder
	private var below: some View {
		if state.showsTerms {
			BehindTheWordsTerms {
				state.page = .deeperLook
			}
			.transition(.opacity.combined(with: .offset(y: 24)))
		} else {
			lookCloser
				.transition(.opacity)
		}
	}

	private var lookCloser: some View {
		VStack(spacing: 20) {
			Text("Looks like a normal reply, right?")
				.font(.title3)
				.multilineTextAlignment(.center)

			Button {
				state.showsTerms = true
			} label: {
				Label("Look closer…", systemImage: "eyeglasses")
					.font(.headline)
			}
			.buttonStyle(.glassProminent)
			.buttonBorderShape(.roundedRectangle(radius: 12))
			.controlSize(.large)
			.accessibilityIdentifier("learn.behindTheWords.lookCloser")
		}
		.frame(maxWidth: .infinity)
	}
}

/// The three terms the lesson sorts by, each with what it means
private struct BehindTheWordsTerms: View {
	let onContinue: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Some terms we're going to learn:")
				.font(.title3.bold())

			VStack(spacing: 10) {
				BehindTheWordsTermRow(kind: .claim, definition: "What the writing wants you to believe or do.")
				BehindTheWordsTermRow(kind: .reason, definition: "Something that, if true, makes the claim more reasonable.")
				BehindTheWordsTermRow(kind: .filler, definition: "Anything you could delete without losing meaning.")
			}

			BehindTheWordsContinueButton(identifier: "terms", action: onContinue)
				.padding(.top, 8)
		}
	}
}

private struct BehindTheWordsTermRow: View {
	let kind: BehindTheWordsKind
	let definition: String

	var body: some View {
		HStack(alignment: .firstTextBaseline, spacing: 12) {
			Image(systemName: kind.symbol)
				.foregroundStyle(kind.color)
				.frame(width: 22)

			VStack(alignment: .leading, spacing: 2) {
				Text(kind.name)
					.font(.headline)
					.foregroundStyle(kind.color)

				Text(definition)
					.font(.body)
			}

			Spacer(minLength: 0)
		}
		.padding(14)
		.background(kind.color.opacity(0.12), in: .rect(cornerRadius: 16))
		.accessibilityElement(children: .combine)
	}
}

extension BehindTheWordsKind {
	/// Its colour wherever the lesson labels a part
	var color: Color {
		switch self {
			case .claim: .green
			case .reason: .blue
			case .filler: .gray
		}
	}

	var symbol: String {
		switch self {
			case .claim: "flag.fill"
			case .reason: "building.columns.fill"
			case .filler: "ellipsis.bubble"
		}
	}
}
