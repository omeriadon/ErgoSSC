//
//  LibraryCategoryView.swift
//  Squint
//
//  Created by Adon Omeri on 1/11/2026.
//

import SwiftUI

struct LibraryCategoryView: View {
	let category: LibraryContent

	var body: some View {
		switch category {
			case .biases:
				LibraryListView<Bias>()

			case .fallacies:
				LibraryListView<Fallacy>()
		}
	}
}
