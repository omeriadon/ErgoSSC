@testable import Defaults
import Foundation
import Testing

private let suite_ = UserDefaults(suiteName: UUID().uuidString)!

@Suite(.serialized)
final class DefaultsUtilitiesTests {
	init() {
		Defaults.removeAll(suite: suite_)
	}

	deinit {
		Defaults.removeAll(suite: suite_)
	}

	@Test
	func taskQueueOrdering() async {
		let queue = TaskQueue()
		let results = _DefaultsAtomic(value: [Int]())

		// Add multiple tasks to ensure they execute in order
		for index in 0 ..< 10 {
			queue.async {
				results.modify { $0.append(index) }
			}
		}

		await queue.flush()

		#expect(results.wrappedValue == Array(0 ..< 10))
	}

	@Test
	func taskQueueConcurrency() async {
		let queue = TaskQueue()
		let counter = _DefaultsAtomic(value: 0)

		// Add multiple tasks that modify the same counter
		for _ in 0 ..< 100 {
			queue.async {
				counter.modify { $0 += 1 }
			}
		}

		await queue.flush()

		#expect(counter.wrappedValue == 100)
	}

	@Test
	func lifetimeAssociation() throws {
		var owner: NSObject? = NSObject()
		var target: NSObject? = NSObject()
		var deinitCalled = false

		weak var weakTarget = target

		do {
			let association = try LifetimeAssociation(of: #require(target), with: #require(owner)) {
				deinitCalled = true
			}

			// Target should still be alive due to association
			target = nil
			#expect(weakTarget != nil)

			// When owner is deallocated, target should be deallocated too
			owner = nil
			#expect(deinitCalled)

			_ = association // Keep association alive
		}

		#expect(weakTarget == nil)
	}

	@Test
	func lifetimeAssociationCancel() throws {
		let owner = NSObject()
		var target: NSObject? = NSObject()
		var deinitCalled = false

		weak var weakTarget = target

		let association = try LifetimeAssociation(of: #require(target), with: owner) {
			deinitCalled = true
		}

		association.cancel()

		// After canceling, target should be deallocatable
		target = nil
		#expect(weakTarget == nil)
		#expect(!deinitCalled) // Deinit handler should not be called when canceled
	}

	@Test
	func atomicOperations() {
		let atomic = _DefaultsAtomic(value: 0)

		// Test basic read/write
		#expect(atomic.wrappedValue == 0)
		atomic.wrappedValue = 42
		#expect(atomic.wrappedValue == 42)

		// Test withValue
		let doubled = atomic.withValue { $0 * 2 }
		#expect(doubled == 84)
		#expect(atomic.wrappedValue == 42) // Original value unchanged

		// Test modify
		let oldValue = atomic.modify { value in
			let old = value
			value = 100
			return old
		}
		#expect(oldValue == 42)
		#expect(atomic.wrappedValue == 100)

		// Test swap
		let swapped = atomic.swap(200)
		#expect(swapped == 100)
		#expect(atomic.wrappedValue == 200)
	}

	@Test
	func atomicConcurrency() async {
		let atomic = _DefaultsAtomic(value: 0)
		let iterations = 1000

		await withTaskGroup(of: Void.self) { group in
			// Start multiple concurrent tasks that increment the atomic value
			for _ in 0 ..< iterations {
				group.addTask {
					atomic.modify { $0 += 1 }
				}
			}
		}

		#expect(atomic.wrappedValue == iterations)
	}

	@Test
	func validKeyPath() {
		#expect(Defaults.isValidKeyPath(name: "validKey"))
		#expect(Defaults.isValidKeyPath(name: "valid_key_123"))
		#expect(Defaults.isValidKeyPath(name: "CamelCaseKey"))
		#expect(Defaults.isValidKeyPath(name: "valid key with spaces")) // Spaces are allowed

		// Invalid key paths
		#expect(!Defaults.isValidKeyPath(name: "@invalidKey"))
		#expect(!Defaults.isValidKeyPath(name: "invalid.key"))
		#expect(!Defaults.isValidKeyPath(name: "key.with.dots"))
		#expect(!Defaults.isValidKeyPath(name: "@"))
		#expect(!Defaults.isValidKeyPath(name: "."))
		#expect(!Defaults.isValidKeyPath(name: "key🦄emoji")) // Non-ASCII
	}

	@Test
	func stringUtilities() {
		let testString = "Hello, World!"
		let data = testString.toData
		#expect(String(data: data, encoding: .utf8) == testString)
	}

	@Test
	func decodableInit() throws {
		struct TestModel: Codable {
			let name: String
			let age: Int
		}

		let jsonString = """
		{"name": "John", "age": 30}
		"""

		let model = try TestModel(jsonString: jsonString)
		#expect(model.name == "John")
		#expect(model.age == 30)

		let jsonData = try #require(jsonString.data(using: .utf8))
		let model2 = try TestModel(jsonData: jsonData)
		#expect(model2.name == "John")
		#expect(model2.age == 30)
	}

	@Test
	func equatableIsEqual() {
		let value1 = 42
		let value2 = 42
		let value3 = 24
		let stringValue = "42"

		#expect(value1.isEqual(value2))
		#expect(!value1.isEqual(value3))
		#expect(!value1.isEqual(stringValue)) // Different types
	}

	@Test
	func sequenceCompact() {
		let optionals: [Int?] = [1, nil, 2, nil, 3]
		let compacted: [Int] = optionals.compact()
		#expect(compacted == [1, 2, 3])

		let noNils: [String?] = ["a", "b", "c"]
		let compactedStrings: [String] = noNils.compact()
		#expect(compactedStrings == ["a", "b", "c"])

		let allNils: [Int?] = [nil, nil, nil]
		let compactedEmpty: [Int] = allNils.compact()
		#expect(compactedEmpty.isEmpty)
	}

	@Test
	func collectionSafeSubscript() {
		let array = [1, 2, 3, 4, 5]

		#expect(array[safe: 0] == 1)
		#expect(array[safe: 2] == 3)
		#expect(array[safe: 4] == 5)
		#expect(array[safe: 5] == nil) // Out of bounds
		#expect(array[safe: -1] == nil) // Negative index

		let emptyArray: [Int] = []
		#expect(emptyArray[safe: 0] == nil)
	}

	@Test
	func collectionIndexed() {
		let array = ["a", "b", "c"]
		let indexed = Array(array.indexed())

		#expect(indexed.count == 3)
		#expect(indexed[0].0 == 0)
		#expect(indexed[0].1 == "a")
		#expect(indexed[1].0 == 1)
		#expect(indexed[1].1 == "b")
		#expect(indexed[2].0 == 2)
		#expect(indexed[2].1 == "c")
	}

	@Test
	func defaultsOptionalProtocol() {
		let optionalInt: Int? = 42
		let nilInt: Int? = nil

		#expect(!optionalInt._defaults_isNil)
		#expect(nilInt._defaults_isNil)

		let optionalString: String? = "hello"
		let nilString: String? = nil

		#expect(!optionalString._defaults_isNil)
		#expect(nilString._defaults_isNil)
	}

	@Test
	func lockWithMethod() {
		let lock = Lock.make()
		let counter = _DefaultsAtomic(value: 0)

		lock.with {
			counter.wrappedValue = 42
		}

		#expect(counter.wrappedValue == 42)

		// Test with throwing closure
		enum TestError: Error {
			case testError
		}

		do {
			try lock.with {
				throw TestError.testError
			}
			#expect(Bool(false), "Should have thrown")
		} catch TestError.testError {
			// Expected
		} catch {
			#expect(Bool(false), "Wrong error type")
		}
	}
}
