//
//  RelatedSection.swift
//  Ergo
//
//  Created by Adon Omeri on 2/11/2026.
//

import SwiftUI

struct RelatedSection: View {
	let list: [CatalogReference]
	var title = "Related"

	var body: some View {
		if !list.isEmpty {
			if list.allSatisfy({ $0.category == .philosophers }) {
				VStack(alignment: .leading, spacing: 20) {
					Text(title)
						.textCase(.uppercase)
						.font(.title3)
						.foregroundStyle(.secondary)

					ForEach(Array(list.enumerated()), id: \.element.id) { index, philosopher in
						NavigationLink(value: philosopher.route) {
							HStack {
								PhilosopherThumbnail(id: philosopher.id)
									.frame(width: 40, height: 40)

								Text(philosopher.name)

								Image(systemName: "chevron.right")
									.imageScale(.small)
							}
							.tint(.primary)
							.padding(.leading, CGFloat(index) * 40)
						}
					}
				}
				.padding(.vertical, 20)
				.padding(.horizontal, 25)
				.frame(maxWidth: .infinity, alignment: .leading)
				.glassEffect(.clear.interactive(), in: RoundedRectangle(cornerRadius: 30))
				.padding(.top)

			} else {
				VStack(alignment: .leading, spacing: 13) {
					Text(title)
						.textCase(.uppercase)
						.foregroundStyle(.secondary)

					VStack(alignment: .leading, spacing: 10) {
						ForEach(list, id: \.id) { target in
							NavigationLink(value: target.route) {
								HStack {
									Text(target.name)
									Spacer()
									Image(systemName: "chevron.right")
								}
							}
						}
					}
				}
				.padding(12)
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
			}
		}
	}
}
