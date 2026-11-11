//
//  CanvasBottomStack.swift
//  Ergo
//
//  Created by Adon Omeri on 8/11/2026.
//

import SwiftUI

/// The notice and the bar under the canvas, which hide while the editor is on top
struct CanvasBottomStack: View {
	let notice: String?
	let mode: CanvasBarMode
	let actions: CanvasBarActions
	let isCovered: Bool
	let motion: Animation?
	let clearNotice: () -> Void

	var body: some View {
		VStack(spacing: 10) {
			if let notice {
				CanvasNoticeView(message: notice, dismiss: clearNotice)
					.transition(.move(edge: .bottom).combined(with: .opacity))
			}

			CanvasBar(mode: mode, actions: actions)
		}
		.padding(.horizontal, 16)
		.padding(.bottom, 8)
		.frame(maxWidth: .infinity)
		.opacity(isCovered ? 0 : 1)
		.allowsHitTesting(!isCovered)
		.animation(motion, value: notice)
		.animation(.easeOut(duration: 0.15), value: isCovered)
	}
}
