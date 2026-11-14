//
//  LookalikeSection.swift
//  Squint
//
//  Created by Adon Omeri on 2/11/2026.
//

import SwiftUI

struct LookalikeSection: View {
	let list: [CatalogLink]
	var title = "Not To Be Confused With:"

	var body: some View {
		if !list.isEmpty {
			VStack(alignment: .leading, spacing: 13) {
				Text(title)
					.textCase(.uppercase)
					.foregroundStyle(.secondary)

				VStack(alignment: .leading, spacing: 4) {
					ForEach(list, id: \.target.id) { lookalike in
						let target = lookalike.target

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
