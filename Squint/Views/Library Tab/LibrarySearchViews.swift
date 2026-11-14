//
//  LibrarySearchViews.swift
//  Squint
//
//  Created by Adon Omeri on 8/11/2026.
//

import SwiftUI

/// What shows before anything is typed into the search
struct LibrarySearchPrompt: View {
	var body: some View {
		VStack(spacing: 20) {
			SquintIcon(size: 64)
			Text("Search anything")
				.font(.title3)
		}
	}
}

/// One match, linking to its page
struct LibrarySearchResultRow: View {
	let result: LibrarySearchEntry

	var body: some View {
		NavigationLink(
			value: LibraryRoute.detail(category: result.category, id: result.id)
		) {
			HStack {
				Label {
					Text(result.name)
				} icon: {
					Image(systemName: result.category.symbol)
						.foregroundStyle(.accent)
				}
				.font(.title3)
				.frame(maxWidth: .infinity, alignment: .leading)
				.labelIconToTitleSpacing(10)

				Spacer()

				Image(systemName: "chevron.right")
					.foregroundStyle(.tertiary)
					.imageScale(.large)
			}
			.contentShape(Rectangle())
		}
		.accessibilityIdentifier("library.search.\(result.category).\(result.id)")
		.padding(.horizontal, 14)
		.padding(.vertical, 13)
		.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
		.contentShape(RoundedRectangle(cornerRadius: 18))
	}
}
