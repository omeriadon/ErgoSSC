// Run with Xcode MCP RunCodeSnippet in the context of CatalogStore.swift.
// This file is outside the app target; it checks the actual app models and bundle.
import Foundation

func expectCatalogFailure(_ operation: () throws -> Void) {
	var rejected = false
	do {
		try operation()
	} catch {
		rejected = true
	}
	precondition(rejected, "Invalid catalog data was accepted")
}

let store = await CatalogStore()
try await store.load()
var references: [CatalogReference] = []
await references.append(contentsOf: store.biases.biases.flatMap(\.related))
await references.append(contentsOf: store.fallacies.fallacies.flatMap(\.related))
await references.append(contentsOf: store.biases.biases.flatMap(\.lookalikes).map(\.target))
await references.append(contentsOf: store.fallacies.fallacies.flatMap(\.lookalikes).map(\.target))
let index = await store.index
for reference in references {
	let resolved = try index.reference(for: reference.id)
	precondition(resolved == reference)
}

let decoder = JSONDecoder()
decoder.userInfo[.catalogIndex] = index
let reference = try decoder.decode(CatalogReference.self, from: Data("\"straw-man\"".utf8))
precondition(reference.name == "Straw man")
precondition(reference.category == .fallacies)

expectCatalogFailure {
	_ = try decoder.decode(CatalogReference.self, from: Data("\"missing-catalog-item\"".utf8))
}

expectCatalogFailure {
	_ = try decoder.decode(CatalogReference.self, from: Data("{\"id\":\"missing-catalog-item\"}".utf8))
}

expectCatalogFailure {
	_ = try decoder.decode(CatalogLink.self, from: Data("{\"targetID\":\"missing-catalog-item\",\"note\":\"Example\"}".utf8))
}

expectCatalogFailure {
	_ = try JSONDecoder().decode(CatalogReference.self, from: Data("\"straw-man\"".utf8))
}

let link = try decoder.decode(CatalogLink.self, from: Data("{\"targetID\":\"straw-man\",\"note\":\"Example\"}".utf8))
precondition(link.target == reference)
precondition(link.note == "Example")

// A reference keeps its original Codable shape without an index.
let referenceData = try JSONEncoder().encode(reference)
let decodedReference = try JSONDecoder().decode(CatalogReference.self, from: referenceData)
precondition(decodedReference == reference)
let referenceObject = try JSONSerialization.jsonObject(with: referenceData) as! [String: Any]
precondition(Set(referenceObject.keys) == ["id", "name", "category"])
let canonical = try decoder.decode(CatalogReference.self, from: Data("{\"id\":\"straw-man\",\"name\":\"Wrong name\"}".utf8))
precondition(canonical == reference)

func checkTag(_ type: (some Decodable).Type) {
	expectCatalogFailure {
		_ = try JSONDecoder().decode(type, from: Data("\"unknown-tag\"".utf8))
	}
}

checkTag(BiasTag.self)
checkTag(FallacyTag.self)

var duplicateIndex = CatalogIndex()
try duplicateIndex.register([reference], category: .fallacies, id: \.id, name: \.name)
expectCatalogFailure {
	try duplicateIndex.register([reference], category: .fallacies, id: \.id, name: \.name)
}

for fallacy in await store.fallacies.fallacies {
	let reference = CatalogReference(id: fallacy.id, name: fallacy.name, category: .fallacies)
	precondition(reference.route == .detail(category: .fallacies, id: fallacy.id))
}

print("Catalog checks passed: both catalogs loaded, \(references.count) references verified, invalid references/tags rejected, references round-trip.")
