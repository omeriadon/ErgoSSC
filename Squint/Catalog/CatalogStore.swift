//
//  CatalogStore.swift
//  Squint
//
//  Created by Adon Omeri on 1/11/2026.
//

import Foundation
import Observation
import SquintCatalog

@MainActor
@Observable
final class CatalogStore {
	private(set) var biases: BiasCatalog = .init(biases: [])
	private(set) var fallacies: FallacyCatalog = .init(fallacies: [])

	private(set) var isLoaded = false

	@ObservationIgnored
	private var loadTask: Task<Void, any Error>?

	func load() async throws {
		guard !isLoaded else {
			return
		}

		if let loadTask {
			try await loadTask.value
			return
		}

		let task = Task {
			let loaded = try await Self.loadCatalog()
			biases = loaded.biases
			fallacies = loaded.fallacies
			index = loaded.index
			isLoaded = true
		}
		loadTask = task
		defer {
			loadTask = nil
		}
		try await task.value
	}

	private(set) var index = CatalogIndex()

	func rebuildIndex() throws {
		var newIndex = CatalogIndex()

		try newIndex.register(fallacies.fallacies, category: .fallacies, id: \.id, name: \.name)
		try newIndex.register(biases.biases, category: .biases, id: \.id, name: \.name)

		index = newIndex
	}

	nonisolated static func decode<T: Decodable & Sendable>(
		_ name: String,
		using index: CatalogIndex
	) throws -> T {
		guard let url = LibraryCatalog.url(of: name) else {
			throw CocoaError(.fileNoSuchFile)
		}

		let data = try Data(contentsOf: url)
		let decoder = JSONDecoder()
		decoder.userInfo[.catalogIndex] = index
		return try decoder.decode(T.self, from: data)
	}

	private nonisolated static func loadCatalog() async throws -> LoadedCatalog {
		async let pendingIndex = Self.makeIndex()
		let newIndex = try await pendingIndex
		async let newBiases: BiasCatalog = Self.decode("biases", using: newIndex)
		async let newFallacies: FallacyCatalog = Self.decode("fallacies", using: newIndex)

		return try await LoadedCatalog(
			biases: newBiases,
			fallacies: newFallacies,
			index: newIndex
		)
	}

	nonisolated static func makeIndex() throws -> CatalogIndex {
		var newIndex = CatalogIndex()
		try registerMetadata("fallacies", category: .fallacies, in: &newIndex)
		try registerMetadata("biases", category: .biases, in: &newIndex)
		return newIndex
	}

	private nonisolated static func registerMetadata(
		_ name: String,
		category: LibraryContent,
		in index: inout CatalogIndex
	) throws {
		guard let url = LibraryCatalog.url(of: name) else {
			throw CocoaError(.fileNoSuchFile)
		}

		let data = try Data(contentsOf: url)
		let metadata = try JSONDecoder().decode([String: [CatalogMetadata]].self, from: data)
		guard let entries = metadata[name] else {
			throw DecodingError.dataCorrupted(.init(
				codingPath: [],
				debugDescription: "Missing catalog collection: \(name)"
			))
		}
		try index.register(entries, category: category, id: \.id, name: \.name)
	}
}

private struct LoadedCatalog: Sendable {
	let biases: BiasCatalog
	let fallacies: FallacyCatalog
	let index: CatalogIndex
}

private struct CatalogMetadata: Decodable, Sendable {
	let id: String
	let name: String
}
