import Foundation

nonisolated struct LibrarySearchEntry: Identifiable, Sendable {
	let id: String
	let name: String
	let category: LibraryContent
	let searchFields: [CatalogSearchField]
}

extension Bias {
	nonisolated var searchFields: [CatalogSearchField] {
		[(name, 1.0)] + aliases.map { ($0, 0.9) } +
			[(summary, 0.5)]
	}
}

extension Fallacy {
	nonisolated var searchFields: [CatalogSearchField] {
		[(name, 1.0)] + aliases.map { ($0, 0.9) } +
			[(summary, 0.5)]
	}
}

extension CatalogStore {
	/// Everything in the library, as something to search
	var searchEntries: [LibrarySearchEntry] {
		let biasResults = biases.biases.map { entry in
			LibrarySearchEntry(
				id: entry.id,
				name: entry.name,
				category: .biases,
				searchFields: entry.searchFields
			)
		}
		let fallacyResults = fallacies.fallacies.map { entry in
			LibrarySearchEntry(
				id: entry.id,
				name: entry.name,
				category: .fallacies,
				searchFields: entry.searchFields
			)
		}
		return biasResults + fallacyResults
	}
}
