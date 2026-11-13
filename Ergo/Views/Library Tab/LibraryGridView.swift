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
			// Only with Apple Intelligence. Without it, the library's search does the job.
			if LibraryFinder.isModelAvailable {
				GridRow {
					NavigationLink(value: LibraryRoute.finder) {
						HStack(alignment: .center) {
							VStack(alignment: .leading, spacing: 8) {
								Image(systemName: "sparkle.magnifyingglass")

								Text("Describe It")
									.font(.title2)

								Text("Noticed something off, but don't know what it's called? Describe it in your own words.")
									.foregroundStyle(.secondary)
							}

							Spacer()

							Image(systemName: "chevron.right")
								.padding(.trailing, 3)
						}
						.padding(22)
						.glassEffect(.clear.tint(.accent).interactive(), in: RoundedRectangle(cornerRadius: 30))
					}
				}

				Spacer()
					.frame(height: 30)
			}

			GridRow {
				NavigationLink(value: LibraryRoute.category(.fallacies)) {
					CardView(title: "Fallacies", color: LibraryContent.fallacies.themeColor)
				}
			}

			Spacer()
				.frame(height: 1)

			GridRow {
				NavigationLink(value: LibraryRoute.category(.biases)) {
					CardView(title: "Biases", color: LibraryContent.biases.themeColor)
				}
			}
		}
	}
}
