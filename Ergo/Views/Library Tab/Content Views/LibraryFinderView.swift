//
//  LibraryFinderView.swift
//  Ergo
//
//  Created by Adon Omeri on 11/11/2026.
//

import SwiftUI

/// Describe something in your own words, and the model on the device finds it in the library
struct LibraryFinderView: View {
	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	@State private var finder = LibraryFinder()
	@State private var description = ""
	@State private var search: Task<Void, Never>?
	@FocusState private var isWriting: Bool

	private static let examples = [
		"Attacking the person instead of what they said",
		"Believing something because everyone else does",
		"A ship that has had every plank replaced",
	]

	private var canFind: Bool {
		!description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}

	/// What the page animates on. The answer changes with every word the model writes, and only a new part of it
	/// should animate in.
	private var stage: String {
		switch finder.state {
			case .idle: "idle"
			case let .working(step): "working \(step)"
			case let .found(answer): "found \(answer.matches.count) \(answer.opening.isEmpty) \(answer.closing.isEmpty)"
			case .nothing: "nothing"
		}
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 16) {
				LibraryFinderField(description: $description, isWriting: $isWriting, canFind: canFind, find: find)

				LibraryFinderResults(state: finder.state, examples: Self.examples) { example in
					description = example
					find()
				}
			}
			.padding(.horizontal, 12)
			.padding(.top, 12)
			.animation(reduceMotion ? nil : .smooth(duration: 0.22), value: stage)
		}
		.scrollDismissesKeyboard(.interactively)
		.scrollEdgeEffectStyle(.soft, for: .all)
		.navigationBarTitleDisplayMode(.inline)
		.toolbarTitleVire("Describe It", "sparkle.magnifyingglass")
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
			TextField("Describe a fallacy, a bias, an idea…", text: $description, axis: .vertical)
				.lineLimit(3 ... 8)
				.focused(isWriting)
				.accessibilityIdentifier("library.finder.field")
				.onChange(of: description) { _, newValue in
					if newValue.count > LibraryFinder.descriptionLimit {
						description = String(newValue.prefix(LibraryFinder.descriptionLimit))
					}
				}

			Button("Find", systemImage: "sparkle.magnifyingglass", action: find)
				.buttonStyle(.glassProminent)
				.disabled(!canFind)
				.accessibilityIdentifier("library.finder.find")
		}
		.padding(14)
		.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
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
					Text("Try one")
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

			case let .working(step):
				HStack(spacing: 10) {
					ProgressView()
					Text(Self.label(for: step))
						.foregroundStyle(.secondary)
						.contentTransition(.numericText())
				}
				.frame(maxWidth: .infinity)
				.padding(.top, 30)
				.transition(.opacity)

			case let .found(answer):
				VStack(alignment: .leading, spacing: 14) {
					if !answer.byModel {
						Text(LibraryFinder.isModelAvailable ? "Nothing fits well. These are the closest." : "Apple Intelligence isn't available, so these are the closest matches by search.")
							.font(.footnote)
							.foregroundStyle(.secondary)
					}

					if !answer.opening.isEmpty {
						Text(answer.opening)
							.padding(.horizontal, 4)
							.transition(.opacity)
					}

					ForEach(answer.matches) { match in
						LibraryFinderRow(match: match)
							.transition(.opacity)
					}

					if !answer.closing.isEmpty {
						Text(answer.closing)
							.padding(.horizontal, 4)
							.transition(.opacity)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.transition(.opacity)

			case .nothing:
				ContentUnavailableView("Nothing Found", systemImage: "sparkle.magnifyingglass", description: Text("Try describing it another way."))
					.padding(.top, 30)
					.transition(.opacity)
		}
	}

	private static func label(for step: LibraryFinder.Step) -> String {
		switch step {
			case .naming: "Working out what to look for"
			case .searching: "Searching the library"
			case let .reading(read, total): "Reading \(read) of \(total)"
			case .ranking: "Thinking it over"
		}
	}
}

/// One entry the finder chose, with what the model says about it, linking to its page
private struct LibraryFinderRow: View {
	let match: LibraryFinder.Match

	var body: some View {
		NavigationLink(value: LibraryRoute.detail(category: match.category, id: match.entryID)) {
			HStack(alignment: .top, spacing: 10) {
				Image(systemName: match.category.symbol)
					.foregroundStyle(.accent)
					.font(.title3)
					.frame(width: 28)

				VStack(alignment: .leading, spacing: 6) {
					Text(match.name)
						.font(.title3)

					Text(match.category.title)
						.textCase(.uppercase)
						.font(.caption2)
						.foregroundStyle(.secondary)

					if let reason = match.reason {
						Text(reason)
							.multilineTextAlignment(.leading)
					} else {
						Text(match.summary)
							.font(.subheadline)
							.foregroundStyle(.secondary)
							.multilineTextAlignment(.leading)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)

				Image(systemName: "chevron.right")
					.foregroundStyle(.tertiary)
					.imageScale(.large)
			}
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.accessibilityIdentifier("library.finder.\(match.category).\(match.entryID)")
		.padding(.horizontal, 14)
		.padding(.vertical, 13)
		.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
		.contentShape(RoundedRectangle(cornerRadius: 18))
	}
}
