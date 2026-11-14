//
//  SquintIcon.swift
//  Squint
//
//  Created by Adon Omeri on 1/11/2026.
//

import SwiftUI

/// The app icon's three lines in Liquid Glass: the middle one tinted orange and in focus, the ones around it clear and faint.
/// Drawn on a 1024 grid, the same as the icon's layers in `Design/Squint icon`.
struct SquintIcon: View {
	var size: CGFloat = 92

	private static let focus = Color(red: 0.878, green: 0.541, blue: 0.180)

	var body: some View {
		let scale = size / 1024

		// No spacing, so the three pieces of glass never melt into each other
		GlassEffectContainer(spacing: 0) {
			VStack(alignment: .leading, spacing: 68 * scale) {
				line(width: 620, glass: .clear.tint(.accent.opacity(0.35)))
				line(width: 620, glass: .regular.tint(Self.focus))
				line(width: 420, glass: .clear.tint(.accent.opacity(0.35)))
			}
			.padding(.leading, 202 * scale)
			.padding(.top, 318 * scale)
			.frame(width: size, height: size, alignment: .topLeading)
		}
		.accessibilityHidden(true)
	}

	private func line(width: CGFloat, glass: Glass) -> some View {
		let scale = size / 1024
		return Color.clear
			.frame(width: width * scale, height: 84 * scale)
			.glassEffect(glass.interactive(), in: .rect(cornerRadius: 42 * scale))
	}
}
