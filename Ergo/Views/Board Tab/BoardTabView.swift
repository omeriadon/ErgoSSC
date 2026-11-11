//
//  BoardTabView.swift
//  Ergo
//
//  Created by Adon Omeri on 1/11/2026.
//

import SwiftUI

/// The Board tab: the current board as a canvas of statements.
struct BoardTabView: View {
	@Environment(BoardStore.self)
	private var boardStore

	/// Undo steps belong to the board they were made on, so they live here and are dropped when the board changes
	@State private var history = CanvasHistory()

	/// How tall the status bar is. The toolbar below it has glass of its own, so only this much of the canvas is dimmed.
	@State private var statusBarHeight: CGFloat = 0

	/// How much of the canvas still shows at the very top of the screen
	private static let dimmest = 0.15

	/// Dimmest at the top of the screen and solid by the bottom of the status bar, along a curve and not a straight line
	private static let topFade = Gradient(stops: (0 ... 12).map { step in
		let place = Double(step) / 12
		return Gradient.Stop(color: .black.opacity(dimmest + (1 - dimmest) * pow(place, 3)), location: place)
	})

	var body: some View {
		ZStack {
			// A different board starts with its own pan, zoom and selection
			CanvasView(history: history)
				.mask {
					VStack(spacing: 0) {
						LinearGradient(gradient: Self.topFade, startPoint: .top, endPoint: .bottom)
							.frame(height: statusBarHeight)
						Color.black
					}
					.ignoresSafeArea()
				}
				.background(
					GeometryReader { geometry in
						Color.clear
							// The view's own inset has the toolbar in it, and the window's is only the status bar
							.onChange(of: geometry.safeAreaInsets.top, initial: true) {
								statusBarHeight = UIApplication.shared.connectedScenes
									.compactMap { ($0 as? UIWindowScene)?.keyWindow }
									.first?.safeAreaInsets.top ?? 0
							}
					}
				)
				.id(boardStore.current.id)
		}
		.containerBackground(for: .navigation) { CanvasBackdrop() }
		.onChange(of: boardStore.current.id) {
			history.clear()
		}
	}
}
