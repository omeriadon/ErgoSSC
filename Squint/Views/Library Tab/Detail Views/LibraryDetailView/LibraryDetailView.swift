//
//  LibraryDetailView.swift
//  Squint
//
//  Created by Adon Omeri on 1/11/2026.
//

import SwiftUI

struct LibraryDetailView: View {
	let category: LibraryContent
	let id: String

	var body: some View {
		switch category {
			case .biases:
				BiasDetailView(id: id)

			case .fallacies:
				FallacyDetailView(id: id)
		}
	}
}
