//
//  CanvasToolbar.swift
//  Ergo
//
//  Created by Adon Omeri on 8/11/2026.
//

import SwiftUI

/// Fit, and a menu for the rest
struct CanvasToolbar: ToolbarContent {
	let board: Board
	let canUndo: Bool
	let canRedo: Bool
	let fit: () -> Void
	let showBoards: () -> Void
	let search: () -> Void
	let undo: () -> Void
	let redo: () -> Void
	let arrange: () -> Void
	let remove: () -> Void

	var body: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button("Fit", systemImage: "arrow.up.left.and.down.right.magnifyingglass", action: fit)
				.accessibilityIdentifier("board.fitButton")
		}

		ToolbarOverflowMenu {
			CanvasMenuContent(
				board: board,
				canUndo: canUndo,
				canRedo: canRedo,
				search: search,
				undo: undo,
				redo: redo,
				arrange: arrange,
				remove: remove
			)
		}
	}
}

private struct CanvasMenuContent: View {
	let board: Board
	let canUndo: Bool
	let canRedo: Bool
	let search: () -> Void
	let undo: () -> Void
	let redo: () -> Void
	let arrange: () -> Void
	let remove: () -> Void

	var body: some View {
		Section {
			Button("Search", systemImage: "magnifyingglass", action: search)
				.accessibilityIdentifier("board.search")
		}

		Section {
			Button("Undo", systemImage: "arrow.uturn.backward", action: undo)
				.disabled(!canUndo)
			Button("Redo", systemImage: "arrow.uturn.forward", action: redo)
				.disabled(!canRedo)
		}

		Section {
			Button("Arrange", systemImage: "rectangle.3.group", action: arrange)
		}

		// A board with nothing on it isn't in the list yet
		if !board.isEmpty {
			BoardActions(board: board, remove: remove)
		}
	}
}
