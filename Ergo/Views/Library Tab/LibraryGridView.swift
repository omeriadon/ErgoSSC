//
//  LibraryGridView.swift
//  Ergo
//
//  Created by Adon Omeri on 3/11/2026.
//

import SwiftUI

struct LibraryGridView: View {
	var body: some View {
		Grid(horizontalSpacing: 12, verticalSpacing: 12) {
			GridRow {
				NavigationLink(value: LibraryRoute.finder) {
					HStack(alignment: .center) {
						VStack(alignment: .leading, spacing: 8) {
							Image(systemName: "sparkle.magnifyingglass")

							Text("Describe It")
								.font(.title2)

							Text("If you don't know the name of a fallacy, but can describe it, try this")
								.foregroundStyle(.secondary)
						}

						Spacer()

						Image(systemName: "chevron.right")
							.padding(.trailing, 3)
					}
					.padding(11)
					.glassEffect(.clear.tint(.accent).interactive(), in: RoundedRectangle(cornerRadius: 22))
				}
				.gridCellColumns(2)
			}

			GridRow {
				NavigationLink(value: LibraryRoute.category(.biases)) {
					CardView(title: "Biases", color: LibraryContent.biases.themeColor)
				}

				NavigationLink(value: LibraryRoute.category(.concepts)) {
					CardView(title: "Concepts", color: LibraryContent.concepts.themeColor)
				}
			}

			GridRow {
				NavigationLink(value: LibraryRoute.category(.fallacies)) {
					CardView(title: "Fallacies", color: LibraryContent.fallacies.themeColor)
				}

				NavigationLink(value: LibraryRoute.category(.symbols)) {
					CardView(title: "Symbols", color: LibraryContent.symbols.themeColor)
				}
			}

			GridRow {
				NavigationLink(value: LibraryRoute.category(.paradoxes)) {
					CardView(title: "Paradoxes", color: LibraryContent.paradoxes.themeColor)
				}

				NavigationLink(value: LibraryRoute.category(.philosophers)) {
					CardView(title: "Philosophers", color: LibraryContent.philosophers.themeColor)
				}
			}

			GridRow {
				NavigationLink(value: LibraryRoute.category(.razors)) {
					CardView(title: "Razors", color: LibraryContent.razors.themeColor)
				}
				NavigationLink(value: LibraryRoute.category(.arguments)) {
					CardView(title: "Arguments", color: LibraryContent.arguments.themeColor)
				}
			}
		}
	}
}
