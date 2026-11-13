// Run with Xcode MCP RunCodeSnippet in the context of CatalogStore.swift.
// This file is outside the app target and exercises the shared async matcher.
import Foundation

@MainActor
func checkLibrarySearch() async throws {
	let store = CatalogStore()
	try await store.load()
	let named = LibrarySearchEntry(
		id: "named",
		name: "Arbitrary",
		category: .fallacies,
		searchFields: [("Arbitrary", 1.0)]
	)
	let incidental = LibrarySearchEntry(
		id: "incidental",
		name: "Other entry",
		category: .fallacies,
		searchFields: [("Other entry", 1.0), ("Arbitrary", 0.5)]
	)
	let ranked = try await CatalogSearch.ranked([incidental, named], query: "Arbitrary") {
		precondition(!Thread.isMainThread, "Matching blocked the main thread")
		return $0.searchFields
	}
	precondition(ranked.first?.id == named.id)
	let tieItems = [
		LibrarySearchEntry(
			id: "tie-a",
			name: "Arbitrary",
			category: .fallacies,
			searchFields: [("Arbitrary", 1.0)]
		),
		LibrarySearchEntry(
			id: "tie-b",
			name: "Arbitrary",
			category: .fallacies,
			searchFields: [("Arbitrary", 1.0)]
		),
		LibrarySearchEntry(
			id: "tie-c",
			name: "Arbitrary",
			category: .fallacies,
			searchFields: [("Arbitrary", 1.0)]
		),
	]
	let fullTies = try await CatalogSearch.ranked(tieItems, query: "Arbitrary") {
		$0.searchFields
	}
	for limit in [0, 1, 2, tieItems.count, tieItems.count + 1] {
		let limitedTies = try await CatalogSearch.ranked(
			tieItems,
			query: "Arbitrary",
			limit: limit
		) { $0.searchFields }
		precondition(limitedTies.map(\.id) == fullTies.prefix(limit).map(\.id))
	}
	let fuzzy = try await CatalogSearch.ranked([named], query: "arbtr") { $0.searchFields }
	precondition(fuzzy.first?.id == named.id)
	let whitespace = try await CatalogSearch.ranked([named], query: " \n ") { $0.searchFields }
	precondition(whitespace.isEmpty)
	let cancelled = Task {
		try await CatalogSearch.ranked([named], query: "Arbitrary") { $0.searchFields }
	}
	cancelled.cancel()
	do {
		_ = try await cancelled.value
		preconditionFailure("Cancelled search returned results")
	} catch is CancellationError {
		// Expected: cancelled work must not publish results.
	}

	for query in ["a", "logic", "straw", "evidence", "arbtr"] {
		let all = try await CatalogSearch.ranked(store.fallacies.fallacies, query: query) { $0.searchFields }
		let limited = try await CatalogSearch.ranked(
			store.fallacies.fallacies,
			query: query,
			limit: CatalogSearch.resultLimit
		) { $0.searchFields }
		precondition(limited.map(\.id) == all.prefix(CatalogSearch.resultLimit).map(\.id))
	}
	for fallacy in store.fallacies.fallacies {
		let expected = [fallacy.name, fallacy.summary] + fallacy.aliases
		precondition(fallacy.searchFields.map(\.text).sorted() == expected.sorted())
	}
	var fields = store.biases.biases.flatMap(\.searchFields)
	fields += store.fallacies.fallacies.flatMap(\.searchFields)
	precondition(!fields.isEmpty)
	print("Verified short search fields, fuzzy ranking, background execution and cancellation.")
}

try await checkLibrarySearch()
