//
//  SquintIcon.swift
//  Squint
//
//  Created by Adon Omeri on 1/11/2026.
//

import SwiftUI

/// The app icon's three lines: the middle one sharp and orange, the ones around it faint and out of focus.
/// Drawn on a 1024 grid, the same as the icon's layers in `Design/Squint icon`.
struct SquintIcon: View {
	var size: CGFloat = 92

	private static let focus = Color(red: 0.878, green: 0.541, blue: 0.180)

	var body: some View {
		ZStack(alignment: .topLeading) {
			line(y: 318, width: 620, faint: true)
			line(y: 470, width: 620, faint: false)
			line(y: 622, width: 420, faint: true)
		}
		.frame(width: size, height: size, alignment: .topLeading)
		.accessibilityHidden(true)
	}

	private func line(y: CGFloat, width: CGFloat, faint: Bool) -> some View {
		let scale = size / 1024
		return RoundedRectangle(cornerRadius: 42 * scale)
			.fill(faint ? AnyShapeStyle(.secondary) : AnyShapeStyle(Self.focus))
			.frame(width: width * scale, height: 84 * scale)
			.blur(radius: faint ? 10 * scale : 0)
			.offset(x: 202 * scale, y: y * scale)
	}
}
