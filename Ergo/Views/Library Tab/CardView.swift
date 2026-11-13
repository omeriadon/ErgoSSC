//
//  CardView.swift
//  Ergo
//
//  Created by Adon Omeri on 3/11/2026.
//

import SwiftUI

struct CardView: View {
	let title: String
	let color: Color

	var body: some View {
		HStack(alignment: .center) {
			VStack(alignment: .leading, spacing: 8) {
				let image = switch title {
					case "Biases":
						"distribute.vertical.center"
					case "Fallacies":
						"repeat.badge.xmark"
					case "Describe It":
						"sparkle.magnifyingglass"
					default:
						""
				}

				Image(systemName: image)

				Text(title)
					.font(.title2)
			}

			Spacer()

			Image(systemName: "chevron.right")
				.padding(.trailing, 3)
		}
		.padding(22)
		.glassEffect(.clear.tint(color).interactive(), in: RoundedRectangle(cornerRadius: 30))
	}
}
