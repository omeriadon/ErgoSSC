//
//  LibraryDetailMenu.swift
//  Ergo
//

import SwiftUI

/// The overflow menu on every library page
struct LibraryDetailMenu: ToolbarContent {
	let reference: CatalogReference

	var body: some ToolbarContent {
		ToolbarOverflowMenu {
			BookmarkToolbarButton(reference: reference)
		}
	}
}
