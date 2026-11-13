// Run with Xcode MCP RunCodeSnippet in the context of CatalogStore.swift.
import Foundation

@MainActor
func checkCatalogLoading() async throws {
	let store = CatalogStore()
	try await withThrowingTaskGroup(of: Void.self) { group in
		for _ in 0 ..< 8 {
			group.addTask {
				try await store.load()
				await MainActor.run {
					precondition(store.isLoaded, "Load returned before publishing the catalog")
					precondition(!store.fallacies.fallacies.isEmpty)
				}
			}
		}
		try await group.waitForAll()
	}

	let original = store.fallacies.fallacies
	try await store.load()
	original.withUnsafeBufferPointer { first in
		store.fallacies.fallacies.withUnsafeBufferPointer { second in
			precondition(first.baseAddress == second.baseAddress, "Repeated load decoded another copy")
		}
	}
	print("Catalog loading checks passed: concurrent callers receive published data and repeat loads reuse storage.")
}

try await checkCatalogLoading()
