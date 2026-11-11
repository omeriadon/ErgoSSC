//
//  CanvasToolbar.swift
//  Ergo
//
//  Created by Adon Omeri on 8/11/2026.
//

import SwiftUI

/// Fit on the left, search and arrange on the right, and a menu for the rest
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

		ToolbarItemGroup(placement: .topBarTrailing) {
			Button("Search", systemImage: "magnifyingglass", action: search)
				.accessibilityIdentifier("board.search")

			Button("Arrange", systemImage: "rectangle.3.group", action: arrange)
		}

		ToolbarOverflowMenu {
			CanvasMenuContent(
				board: board,
				canUndo: canUndo,
				canRedo: canRedo,
				undo: undo,
				redo: redo,
				remove: remove
			)
		}
	}
}

private struct CanvasMenuContent: View {
	let board: Board
	let canUndo: Bool
	let canRedo: Bool
	let undo: () -> Void
	let redo: () -> Void
	let remove: () -> Void

	var body: some View {
		Section {
			Button("Undo", systemImage: "arrow.uturn.backward", action: undo)
				.disabled(!canUndo)
			Button("Redo", systemImage: "arrow.uturn.forward", action: redo)
				.disabled(!canRedo)
		}

		// A board with nothing on it isn't in the list yet
		if !board.isEmpty {
			BoardActions(board: board, remove: remove)
		}
	}
}
