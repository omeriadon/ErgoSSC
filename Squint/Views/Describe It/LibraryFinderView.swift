//
//  LibraryFinderView.swift
//  Squint
//
//  Created by Adon Omeri on 11/11/2026.
//

import SquintCatalog
import SwiftUI

/// Describe something in your own words, and the model on the device names it
struct LibraryFinderView: View {
	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	@State private var finder = LibraryFinder()
	@State private var description = ""
	@State private var search: Task<Void, Never>?
	@FocusState private var isWriting: Bool

	/// Situations, not definitions, since that's how people notice these
	private static let examples = [
		"I said I'd like to eat less meat and my friend said \"so you want everyone to be vegan?\"",
		"I pointed out a problem with the plan, and they said I'm too young to understand",
		"My mum said either I quit my game or I'll fail all my exams",
		"The ad only showed the five-star reviews and hid all the one-star ones",
		"I only seem to notice the news that agrees with what I already think",
		"The first price I saw was so high that the sale price felt like a bargain",
	]

	private var canFind: Bool {
		!description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}

	/// What the page animates on. The answer changes with every word the model writes, and only a new part of it
	/// should animate in.
	private var stage: String {
		switch finder.state {
			case .idle: "idle"
			case .working: "working"
			case let .found(answer): "found \(answer.matches.count) \(answer.opening.isEmpty)"
			case .nothing: "nothing"
			case .failed: "failed"
		}
	}

	var body: some View {
		Group {
			if LibraryFinder.isModelAvailable {
				finderPage
			} else {
				LibraryFinderSearchPage()
			}
		}
		.navigationBarTitleDisplayMode(.inline)
		.toolbarTitleVire("Describe It", "sparkle.magnifyingglass")
	}

	private var finderPage: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 16) {
				LibraryFinderField(description: $description, isWriting: $isWriting, canFind: canFind, find: find)

				LibraryFinderResults(state: finder.state, examples: Self.examples) { example in
					description = example
					find()
				}

				LibraryFinderCredit()
					.padding(.top, 8)
			}
			.padding(.horizontal, 12)
			.padding(.top, 12)
			.padding(.bottom, 16)
			.animation(reduceMotion ? nil : .smooth(duration: 0.22), value: stage)
		}
		.scrollDismissesKeyboard(.interactively)
		.scrollEdgeEffectStyle(.soft, for: .all)
		.onChange(of: description) {
			// What's shown was found for other words
			if finder.state != .idle {
				search?.cancel()
				finder.reset()
			}
		}
		.onDisappear {
			search?.cancel()
		}
	}

	private func find() {
		guard canFind else { return }
		isWriting = false
		search?.cancel()
		let description = description
		search = Task {
			await finder.find(description)
		}
	}
}

private struct LibraryFinderField: View {
	@Binding var description: String
	var isWriting: FocusState<Bool>.Binding
	let canFind: Bool
	let find: () -> Void

	var body: some View {
		VStack(alignment: .trailing, spacing: 10) {
			// No upper line limit: a field that scrolls inside itself cuts its text off at the padding, so it grows and
			// the page scrolls instead. `descriptionLimit` is what stops it.

			TextField("Describe something someone said, or a way of thinking you've noticed…", text: $description, axis: .vertical)
				.lineLimit(3...)
				.focused(isWriting)
				.accessibilityIdentifier("library.finder.field")
				.onChange(of: description) { _, newValue in
					if newValue.count > LibraryFinder.descriptionLimit {
						description = String(newValue.prefix(LibraryFinder.descriptionLimit))
					}
				}

			Button("Find", systemImage: "sparkle.magnifyingglass", action: find)
				.buttonStyle(.glass(.clear.tint(canFind ? .accent : .clear).interactive()))
				.buttonBorderShape(.roundedRectangle(radius: 14))
				.disabled(!canFind)
				.accessibilityIdentifier("library.finder.find")
		}
		.padding(14)
		.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
	}
}

private struct LibraryFinderResults: View {
	let state: LibraryFinder.State
	let examples: [String]
	let tryExample: (String) -> Void

	var body: some View {
		switch state {
			case .idle:
				VStack(alignment: .leading, spacing: 10) {
					Text("Or try one of these")
						.font(.footnote)
						.foregroundStyle(.secondary)

					ForEach(examples, id: \.self) { example in
						Button {
							tryExample(example)
						} label: {
							Text(example)
								.frame(maxWidth: .infinity, alignment: .leading)
								.padding(.horizontal, 14)
								.padding(.vertical, 11)
								.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
								.contentShape(RoundedRectangle(cornerRadius: 18))
						}
						.buttonStyle(.plain)
					}
				}
				.transition(.opacity)

			case .working:
				HStack(spacing: 10) {
					ProgressView()
					Text("Thinking it over")
						.foregroundStyle(.secondary)
				}
				.frame(maxWidth: .infinity)
				.padding(.top, 30)
				.transition(.opacity)

			case let .found(answer):
				VStack(alignment: .leading, spacing: 14) {
					if !answer.opening.isEmpty {
						Text(answer.opening)
							.padding(.horizontal, 4)
							.transition(.opacity)
					}

					ForEach(answer.matches) { match in
						LibraryFinderRow(match: match)
							.transition(.opacity)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.transition(.opacity)

			case .nothing:
				ContentUnavailableView(
					"No Match",
					systemImage: "sparkle.magnifyingglass",
					description: Text("That doesn't match anything Squint knows about yet. Thanks for trying, though!")
				)
				.padding(.top, 30)
				.transition(.opacity)

			case .failed:
				ContentUnavailableView(
					"Couldn't Answer",
					systemImage: "exclamationmark.bubble",
					description: Text("Describe It couldn't answer that just now. Please try again, or describe it another way.")
				)
				.padding(.top, 30)
				.transition(.opacity)
		}
	}
}

/// Without the model: a note, and a search over the whole catalog
private struct LibraryFinderSearchPage: View {
	@State private var query = ""

	private var entries: [LibraryEntryText] {
		LibraryEntryMatcher.search(query, in: LibraryCatalog.shared?.entries ?? [])
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 14) {
				Text("Describe It needs Apple Intelligence. Turn it on in Settings, or try on a device that supports it. You can still search what Squint knows about.")
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.padding(.horizontal, 4)

				TextField("Search by name or keyword", text: $query)
					.autocorrectionDisabled()
					.padding(14)
					.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
					.accessibilityIdentifier("library.finder.search")

				ForEach(entries) { entry in
					LibraryFinderEntryCard(entry: entry)
				}

				LibraryFinderCredit()
					.padding(.top, 8)
			}
			.padding(.horizontal, 12)
			.padding(.vertical, 12)
		}
		.scrollDismissesKeyboard(.interactively)
		.scrollEdgeEffectStyle(.soft, for: .all)
	}
}

/// One catalog entry: its name, kind and plain description
private struct LibraryFinderEntryCard: View {
	let entry: LibraryEntryText

	private var isBias: Bool {
		entry.category == "biases"
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(entry.name)
				.font(.title3)

			Text(isBias ? "Bias" : "Fallacy")
				.textCase(.uppercase)
				.font(.caption2)
				.foregroundStyle(.secondary)

			Text(entry.plain)
				.font(.subheadline)
		}
		.multilineTextAlignment(.leading)
		.frame(maxWidth: .infinity, alignment: .leading)
		.accessibilityElement(children: .combine)
		.padding(.horizontal, 14)
		.padding(.vertical, 13)
		.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
	}
}

/// One entry the finder chose, with what the model says about it
private struct LibraryFinderRow: View {
	let match: LibraryFinder.Match

	var body: some View {
		HStack(alignment: .top, spacing: 10) {
			Image(systemName: match.symbol)
				.foregroundStyle(.accent)
				.font(.title3)
				.frame(width: 28)

			VStack(alignment: .leading, spacing: 6) {
				Text(match.name)
					.font(.title3)

				Text(match.kind)
					.textCase(.uppercase)
					.font(.caption2)
					.foregroundStyle(.secondary)

				if let reason = match.reason {
					Text(reason)
				}

				Text(match.plain)
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			.multilineTextAlignment(.leading)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.accessibilityElement(children: .combine)
		.accessibilityIdentifier("library.finder.\(match.id)")
		.padding(.horizontal, 14)
		.padding(.vertical, 13)
		.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
	}
}

/// Where the fallacies and biases came from, as Wikipedia asks
private struct LibraryFinderCredit: View {
	var body: some View {
		Text("The fallacies and biases were drawn from Wikipedia's [List of fallacies](https://en.wikipedia.org/wiki/List_of_fallacies) and [List of cognitive biases](https://en.wikipedia.org/wiki/List_of_cognitive_biases), whose text is under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).")
			.font(.caption)
			.foregroundStyle(.secondary)
			.multilineTextAlignment(.leading)
			.frame(maxWidth: .infinity)
	}
}
