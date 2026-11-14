//
//  SquintIcon.swift
//  Squint
//
//  Created by Adon Omeri on 1/11/2026.
//

import SwiftUI

/// The app icon's three lines in Liquid Glass: the middle one tinted orange and in focus, the ones around it faint.
/// Drawn on a 1024 grid, the same as the icon's layers in `Design/Squint icon`.
struct SquintIcon: View {
	var size: CGFloat = 92
	/// On a glass tile in the icon's brown gradient, shaped like the app icon, with the faint lines a subtle white like the icon's
	var onTile = false

	private static let focus = Color(red: 0.878, green: 0.541, blue: 0.180)

	var body: some View {
		let scale = size / 1024

		// No spacing, so the three pieces of glass never melt into each other
		GlassEffectContainer(spacing: 0) {
			VStack(alignment: .leading, spacing: 68 * scale) {
				line(width: 620, glass: faint)
				line(width: 620, glass: .regular.tint(Self.focus))
				line(width: 420, glass: faint)
			}
			.padding(.leading, 202 * scale)
			.padding(.top, 318 * scale)
			.frame(width: size, height: size, alignment: .topLeading)
		}
		.background {
			// Outside the lines' container, so they sit on it rather than melting into it
			if onTile {
				tile
			}
		}
		.accessibilityHidden(true)
	}

	/// The app icon's brown, lighter at the top like its gradient, under clear glass for the edge and shine
	private var tile: some View {
		let shape = RoundedRectangle(cornerRadius: size * 0.2237)
		return ZStack {
			shape.fill(Self.tileGradient)

			// Reacts to a touch like the lines on it do
			Color.clear
				.contentShape(shape)
				.glassEffect(.clear.interactive(), in: shape)
		}
	}

	private static let tileGradient = LinearGradient(
		colors: [Color(red: 0.62, green: 0.43, blue: 0.27), Color(red: 0.43, green: 0.28, blue: 0.16)],
		startPoint: .top,
		endPoint: .bottom
	)

	private var faint: Glass {
		onTile ? .regular.tint(.white.opacity(0.35)) : .regular.tint(.accent.opacity(0.35))
	}

	private func line(width: CGFloat, glass: Glass) -> some View {
		let scale = size / 1024
		let shape = RoundedRectangle(cornerRadius: 42 * scale)
		// Clear colour isn't touchable on its own, so the shape is what takes the touch
		return Color.clear
			.frame(width: width * scale, height: 84 * scale)
			.contentShape(shape)
			.glassEffect(glass.interactive(), in: shape)
	}
}
