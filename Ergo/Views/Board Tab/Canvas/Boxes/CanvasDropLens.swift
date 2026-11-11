//
//  CanvasDropLens.swift
//  Ergo
//
//  Created by Adon Omeri on 6/11/2026.
//

import ErgoLogic
import SwiftUI

/// The card an arrow would make if it was let go here: a pane of material under the finger, the size of a box.
/// `CanvasBoardView` places it and decides when it shows, this only draws it.
struct CanvasDropLens: View {
	static let size = CGSize(width: CanvasLayout.boxSize.width, height: CanvasLayout.boxSize.height)

	var body: some View {
		Color.clear
			.glassEffect(.clear, in: RoundedRectangle(cornerRadius: StatementBoxView.corner))
	}
}
