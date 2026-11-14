//
//  LibraryListRow.swift
//  Squint
//
//  Created by Adon Omeri on 8/11/2026.
//

import SwiftUI

/// One entry in a category's list, linking to its page
struct LibraryListRow<Item: LibraryListItem>: View, Equatable {
	let item: Item

	/// What the row shows, so the list can skip re-rendering a row when none of it changed
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.item.id == rhs.item.id && lhs.item.name == rhs.item.name
	}

	var body: some View {
		NavigationLink(
			value: LibraryRoute.detail(
				category: Item.category,
				id: item.id
			)
		) {
			item.row
				.frame(maxWidth: .infinity, alignment: .leading)
				.accessibilityIdentifier("library.\(Item.category.rawValue).\(item.id)")
		}
		.buttonStyle(.plain)
	}
}
