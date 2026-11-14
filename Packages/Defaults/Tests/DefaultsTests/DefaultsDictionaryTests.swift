import Defaults
import Foundation
import Testing

private let suite_ = createSuite()

private let fixtureDictionary = ["0": "Hank"]

private let fixtureArray = ["Hank", "Chen"]

private extension Defaults.Keys {
	static let dictionary = Key<[String: String]>("dictionary", default: fixtureDictionary, suite: suite_)
}

@Suite(.serialized)
final class DefaultsDictionaryTests {
	init() {
		Defaults.removeAll(suite: suite_)
	}

	deinit {
		Defaults.removeAll(suite: suite_)
	}

	@Test
	func testKey() {
		let key = Defaults.Key<[String: String]>("independentDictionaryStringKey", default: fixtureDictionary, suite: suite_)
		#expect(Defaults[key]["0"] == fixtureDictionary["0"])
		let newValue = "John"
		Defaults[key]["0"] = newValue
		#expect(Defaults[key]["0"] == newValue)
	}

	@Test
	func optionalKey() {
		let key = Defaults.Key<[String: String]?>("independentDictionaryOptionalKey", suite: suite_) // swiftlint:disable:this discouraged_optional_collection
		#expect(Defaults[key] == nil)
		Defaults[key] = fixtureDictionary
		#expect(Defaults[key]?["0"] == fixtureDictionary["0"])
		Defaults[key] = nil
		#expect(Defaults[key] == nil)
		let newValue = ["0": "Chen"]
		Defaults[key] = newValue
		#expect(Defaults[key]?["0"] == newValue["0"])
	}

	@Test
	func nestedKey() {
		let key = Defaults.Key<[String: [String: String]]>("independentDictionaryNestedKey", default: ["0": fixtureDictionary], suite: suite_)
		#expect(Defaults[key]["0"]?["0"] == "Hank")
		let newName = "Chen"
		Defaults[key]["0"]?["0"] = newName
		#expect(Defaults[key]["0"]?["0"] == newName)
	}

	@Test
	func arrayKey() {
		let key = Defaults.Key<[String: [String]]>("independentDictionaryArrayKey", default: ["0": fixtureArray], suite: suite_)
		#expect(Defaults[key]["0"] == fixtureArray)
		let newName = "Chen"
		Defaults[key]["0"]?[0] = newName
		#expect(Defaults[key]["0"] == [newName, fixtureArray[1]])
	}

	@Test
	func intKey() {
		let fixture = [1: "x"]
		let key = Defaults.Key<[Int: String]>("independentDictionaryIntKey", default: fixture, suite: suite_)
		#expect(Defaults[key][1] == fixture[1])
		let newValue = "John"
		Defaults[key][1] = newValue
		#expect(Defaults[key][1] == newValue)
	}

	@Test
	func type() {
		#expect(Defaults[.dictionary]["0"] == fixtureDictionary["0"])
		let newName = "Chen"
		Defaults[.dictionary]["0"] = newName
		#expect(Defaults[.dictionary]["0"] == newName)
	}
}
