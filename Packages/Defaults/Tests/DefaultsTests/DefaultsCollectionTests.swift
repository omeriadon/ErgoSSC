import Defaults
import Foundation
import Testing

private let suite_ = createSuite()

struct Bag<Element: Defaults.Serializable>: Collection {
	var items: [Element]

	var startIndex: Int {
		items.startIndex
	}

	var endIndex: Int {
		items.endIndex
	}

	mutating func insert(element: Element, at: Int) {
		items.insert(element, at: at)
	}

	func index(after index: Int) -> Int {
		items.index(after: index)
	}

	subscript(position: Int) -> Element {
		items[position]
	}
}

extension Bag: Defaults.CollectionSerializable {
	init(_ elements: [Element]) {
		items = elements
	}
}

private let fixtureCollection = ["Juice", "Apple", "Banana"]

private extension Defaults.Keys {
	static let collection = Key<Bag<String>>("collection", default: Bag(items: fixtureCollection), suite: suite_)
	static let collectionArray = Key<[Bag<String>]>("collectionArray", default: [Bag(items: fixtureCollection)], suite: suite_)
	static let collectionDictionary = Key<[String: Bag<String>]>("collectionDictionary", default: ["0": Bag(items: fixtureCollection)], suite: suite_)
}

@Suite(.serialized)
final class DefaultsCollectionTests {
	init() {
		Defaults.removeAll(suite: suite_)
	}

	deinit {
		Defaults.removeAll(suite: suite_)
	}

	@Test
	func testKey() {
		let key = Defaults.Key<Bag<String>>("independentCollectionKey", default: Bag(items: fixtureCollection), suite: suite_)
		Defaults[key].insert(element: "123", at: 0)
		#expect(Defaults[key][0] == "123")
	}

	@Test
	func optionalKey() {
		let key = Defaults.Key<Bag<String>?>("independentCollectionOptionalKey", suite: suite_)
		#expect(Defaults[key] == nil)
		Defaults[key] = Bag(items: [])
		Defaults[key]?.insert(element: fixtureCollection[0], at: 0)
		#expect(Defaults[key]?[0] == fixtureCollection[0])
		Defaults[key]?.insert(element: fixtureCollection[1], at: 1)
		#expect(Defaults[key]?[1] == fixtureCollection[1])
	}

	@Test
	func arrayKey() {
		let key = Defaults.Key<[Bag<String>]>("independentCollectionArrayKey", default: [Bag(items: [fixtureCollection[0]])], suite: suite_)
		Defaults[key].append(Bag(items: [fixtureCollection[1]]))
		#expect(Defaults[key][1][0] == fixtureCollection[1])
		Defaults[key][0].insert(element: fixtureCollection[2], at: 1)
		#expect(Defaults[key][0][1] == fixtureCollection[2])
	}

	@Test
	func arrayOptionalKey() {
		let key = Defaults.Key<[Bag<String>]?>("independentCollectionArrayOptionalKey", suite: suite_) // swiftlint:disable:this discouraged_optional_collection
		#expect(Defaults[key] == nil)
		Defaults[key] = [Bag(items: [fixtureCollection[0]])]
		Defaults[key]?.append(Bag(items: [fixtureCollection[1]]))
		#expect(Defaults[key]?[1][0] == fixtureCollection[1])
		Defaults[key]?[0].insert(element: fixtureCollection[2], at: 1)
		#expect(Defaults[key]?[0][1] == fixtureCollection[2])
	}

	@Test
	func nestedArrayKey() {
		let key = Defaults.Key<[[Bag<String>]]>("independentCollectionNestedArrayKey", default: [[Bag(items: [fixtureCollection[0]])]], suite: suite_)
		Defaults[key][0].append(Bag(items: [fixtureCollection[1]]))
		Defaults[key].append([Bag(items: [fixtureCollection[2]])])
		#expect(Defaults[key][0][0][0] == fixtureCollection[0])
		#expect(Defaults[key][0][1][0] == fixtureCollection[1])
		#expect(Defaults[key][1][0][0] == fixtureCollection[2])
	}

	@Test
	func arrayDictionaryKey() {
		let key = Defaults.Key<[[String: Bag<String>]]>("independentCollectionArrayDictionaryKey", default: [["0": Bag(items: [fixtureCollection[0]])]], suite: suite_)
		Defaults[key][0]["1"] = Bag(items: [fixtureCollection[1]])
		Defaults[key].append(["0": Bag(items: [fixtureCollection[2]])])
		#expect(Defaults[key][0]["0"]?[0] == fixtureCollection[0])
		#expect(Defaults[key][0]["1"]?[0] == fixtureCollection[1])
		#expect(Defaults[key][1]["0"]?[0] == fixtureCollection[2])
	}

	@Test
	func dictionaryKey() {
		let key = Defaults.Key<[String: Bag<String>]>("independentCollectionDictionaryKey", default: ["0": Bag(items: [fixtureCollection[0]])], suite: suite_)
		Defaults[key]["0"]?.insert(element: fixtureCollection[1], at: 1)
		Defaults[key]["1"] = Bag(items: [fixtureCollection[2]])
		#expect(Defaults[key]["0"]?[0] == fixtureCollection[0])
		#expect(Defaults[key]["0"]?[1] == fixtureCollection[1])
		#expect(Defaults[key]["1"]?[0] == fixtureCollection[2])
	}

	@Test
	func dictionaryOptionalKey() {
		let key = Defaults.Key<[String: Bag<String>]?>("independentCollectionDictionaryOptionalKey", suite: suite_) // swiftlint:disable:this discouraged_optional_collection
		#expect(Defaults[key] == nil)
		Defaults[key] = ["0": Bag(items: [fixtureCollection[0]])]
		Defaults[key]?["0"]?.insert(element: fixtureCollection[1], at: 1)
		Defaults[key]?["1"] = Bag(items: [fixtureCollection[2]])
		#expect(Defaults[key]?["0"]?[0] == fixtureCollection[0])
		#expect(Defaults[key]?["0"]?[1] == fixtureCollection[1])
		#expect(Defaults[key]?["1"]?[0] == fixtureCollection[2])
	}

	@Test
	func dictionaryArrayKey() {
		let key = Defaults.Key<[String: [Bag<String>]]>("independentCollectionDictionaryArrayKey", default: ["0": [Bag(items: [fixtureCollection[0]])]], suite: suite_)
		Defaults[key]["0"]?[0].insert(element: fixtureCollection[1], at: 1)
		Defaults[key]["1"] = [Bag(items: [fixtureCollection[2]])]
		#expect(Defaults[key]["0"]?[0][0] == fixtureCollection[0])
		#expect(Defaults[key]["0"]?[0][1] == fixtureCollection[1])
		#expect(Defaults[key]["1"]?[0][0] == fixtureCollection[2])
	}

	@Test
	func type() {
		Defaults[.collection].insert(element: "123", at: 0)
		#expect(Defaults[.collection][0] == "123")
	}

	@Test
	func arrayType() {
		Defaults[.collectionArray].append(Bag(items: [fixtureCollection[0]]))
		Defaults[.collectionArray][0].insert(element: "123", at: 0)
		#expect(Defaults[.collectionArray][0][0] == "123")
		#expect(Defaults[.collectionArray][1][0] == fixtureCollection[0])
	}

	@Test
	func dictionaryType() {
		Defaults[.collectionDictionary]["1"] = Bag(items: [fixtureCollection[0]])
		Defaults[.collectionDictionary]["0"]?.insert(element: "123", at: 0)
		#expect(Defaults[.collectionDictionary]["0"]?[0] == "123")
		#expect(Defaults[.collectionDictionary]["1"]?[0] == fixtureCollection[0])
	}
}
