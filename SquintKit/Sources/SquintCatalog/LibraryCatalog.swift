//
//  LibraryCatalog.swift
//  SquintKit
//
//  Created by Adon Omeri on 6/11/2026.
//

import Foundation

/// Squint's small catalog of fallacies and biases as plain text, for Describe It to offer to the model.
public struct LibraryCatalog: Sendable {
	public static let categories = ["biases", "fallacies"]

	/// Loaded the first time it's needed. Nil only if the package's resources are broken.
	public static let shared = try? LibraryCatalog.load()

	public let entries: [LibraryEntryText]

	public init(entries: [LibraryEntryText]) {
		self.entries = entries
	}

	private static func url(of name: String) -> URL? {
		Bundle.module.url(forResource: name, withExtension: "json")
	}

	public static func load() throws -> LibraryCatalog {
		var entries: [LibraryEntryText] = []
		for category in categories {
			guard let url = url(of: category) else {
				throw CocoaError(.fileNoSuchFile)
			}
			entries += try LibraryEntryText.entries(in: Data(contentsOf: url), category: category)
		}
		return LibraryCatalog(entries: entries)
	}
}

/// One entry of the catalog, whichever kind it is
public struct LibraryEntryText: Sendable, Hashable, Identifiable {
	public let category: String
	public let id: String
	public let name: String
	/// Other names it goes by
	public let aliases: [String]
	/// What it is in everyday words, with a small example. It's what Describe It shows.
	public let plain: String

	public init(category: String, id: String, name: String, aliases: [String] = [], plain: String = "") {
		self.category = category
		self.id = id
		self.name = name
		self.aliases = aliases
		self.plain = plain
	}

	static func entries(in data: Data, category: String) throws -> [LibraryEntryText] {
		guard
			let file = try JSONSerialization.jsonObject(with: data) as? [String: Any],
			let items = file[category] as? [[String: Any]]
		else {
			throw CocoaError(.fileReadCorruptFile)
		}

		return items.compactMap { item in
			guard let id = item["id"] as? String, let name = item["name"] as? String else { return nil }
			return LibraryEntryText(
				category: category,
				id: id,
				name: name,
				aliases: item["aliases"] as? [String] ?? [],
				plain: item["plain"] as? String ?? ""
			)
		}
	}
}
