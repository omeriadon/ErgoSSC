import Defaults
import Foundation
import Testing

private let suite_ = createSuite()

private enum FixtureEnum: String, Defaults.Serializable {
	case tenMinutes = "10 Minutes"
	case halfHour = "30 Minutes"
	case oneHour = "1 Hour"
}

private extension Defaults.Keys {
	static let `enum` = Key<FixtureEnum>("enum", default: .tenMinutes, suite: suite_)
	static let enumArray = Key<[FixtureEnum]>("array_enum", default: [.tenMinutes], suite: suite_)
	static let enumDictionary = Key<[String: FixtureEnum]>("dictionary_enum", default: ["0": .tenMinutes], suite: suite_)
}

@Suite(.serialized)
final class DefaultsEnumTests {
	init() {
		Defaults.removeAll(suite: suite_)
	}

	deinit {
		Defaults.removeAll(suite: suite_)
	}

	@Test
	func testKey() {
		let key = Defaults.Key<FixtureEnum>("independentEnumKey", default: .tenMinutes, suite: suite_)
		#expect(Defaults[key] == .tenMinutes)
		Defaults[key] = .halfHour
		#expect(Defaults[key] == .halfHour)
	}

	@Test
	func optionalKey() {
		let key = Defaults.Key<FixtureEnum?>("independentEnumOptionalKey", suite: suite_)
		#expect(Defaults[key] == nil)
		Defaults[key] = .tenMinutes
		#expect(Defaults[key] == .tenMinutes)
	}

	@Test
	func arrayKey() {
		let key = Defaults.Key<[FixtureEnum]>("independentEnumArrayKey", default: [.tenMinutes], suite: suite_)
		#expect(Defaults[key][0] == .tenMinutes)
		Defaults[key].append(.halfHour)
		#expect(Defaults[key][0] == .tenMinutes)
		#expect(Defaults[key][1] == .halfHour)
	}

	@Test
	func arrayOptionalKey() {
		let key = Defaults.Key<[FixtureEnum]?>("independentEnumArrayOptionalKey", suite: suite_) // swiftlint:disable:this discouraged_optional_collection
		#expect(Defaults[key] == nil)
		Defaults[key] = [.tenMinutes]
		Defaults[key]?.append(.halfHour)
		#expect(Defaults[key]?[0] == .tenMinutes)
		#expect(Defaults[key]?[1] == .halfHour)
	}

	@Test
	func nestedArrayKey() {
		let key = Defaults.Key<[[FixtureEnum]]>("independentEnumNestedArrayKey", default: [[.tenMinutes]], suite: suite_)
		#expect(Defaults[key][0][0] == .tenMinutes)
		Defaults[key][0].append(.halfHour)
		Defaults[key].append([.oneHour])
		#expect(Defaults[key][0][1] == .halfHour)
		#expect(Defaults[key][1][0] == .oneHour)
	}

	@Test
	func arrayDictionaryKey() {
		let key = Defaults.Key<[[String: FixtureEnum]]>("independentEnumArrayDictionaryKey", default: [["0": .tenMinutes]], suite: suite_)
		#expect(Defaults[key][0]["0"] == .tenMinutes)
		Defaults[key][0]["1"] = .halfHour
		Defaults[key].append(["0": .oneHour])
		#expect(Defaults[key][0]["1"] == .halfHour)
		#expect(Defaults[key][1]["0"] == .oneHour)
	}

	@Test
	func dictionaryKey() {
		let key = Defaults.Key<[String: FixtureEnum]>("independentEnumDictionaryKey", default: ["0": .tenMinutes], suite: suite_)
		#expect(Defaults[key]["0"] == .tenMinutes)
		Defaults[key]["1"] = .halfHour
		#expect(Defaults[key]["0"] == .tenMinutes)
		#expect(Defaults[key]["1"] == .halfHour)
	}

	@Test
	func dictionaryOptionalKey() {
		let key = Defaults.Key<[String: FixtureEnum]?>("independentEnumDictionaryOptionalKey", suite: suite_) // swiftlint:disable:this discouraged_optional_collection
		#expect(Defaults[key] == nil)
		Defaults[key] = ["0": .tenMinutes]
		#expect(Defaults[key]?["0"] == .tenMinutes)
	}

	@Test
	func dictionaryArrayKey() {
		let key = Defaults.Key<[String: [FixtureEnum]]>("independentEnumDictionaryKey", default: ["0": [.tenMinutes]], suite: suite_)
		#expect(Defaults[key]["0"]?[0] == .tenMinutes)
		Defaults[key]["0"]?.append(.halfHour)
		Defaults[key]["1"] = [.oneHour]
		#expect(Defaults[key]["0"]?[1] == .halfHour)
		#expect(Defaults[key]["1"]?[0] == .oneHour)
	}

	@Test
	func type() {
		#expect(Defaults[.enum] == .tenMinutes)
		Defaults[.enum] = .halfHour
		#expect(Defaults[.enum] == .halfHour)
	}

	@Test
	func arrayType() {
		#expect(Defaults[.enumArray][0] == .tenMinutes)
		Defaults[.enumArray][0] = .oneHour
		#expect(Defaults[.enumArray][0] == .oneHour)
	}

	@Test
	func dictionaryType() {
		#expect(Defaults[.enumDictionary]["0"] == .tenMinutes)
		Defaults[.enumDictionary]["0"] = .halfHour
		#expect(Defaults[.enumDictionary]["0"] == .halfHour)
	}
}
