//
//  RelatedSection.swift
//  Squint
//
//  Created by Adon Omeri on 2/11/2026.
//

import SwiftUI

struct RelatedSection: View {
	let list: [CatalogReference]
	var title = "Related"

	var body: some View {
		if !list.isEmpty {
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
