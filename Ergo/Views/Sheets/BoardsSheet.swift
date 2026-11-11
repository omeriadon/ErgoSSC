//
//  BoardsSheet.swift
//  Ergo
//
//  Created by Adon Omeri on 5/11/2026.
//

import SwiftUI

struct BoardsSheet: View {
	@Environment(NavigationManager.self)
	private var navigation

	@Environment(BoardStore.self)
	private var boardStore

	@State private var renaming: Renaming<Board.ID>?

	@State private var isShowingArchived = false

	private var list: some View {
		List {
			// Always there, since pulling a sheet's list down moves the sheet and never gets past the top
			if !boardStore.archivedBoards.isEmpty {
				ArchivedRow(count: boardStore.archivedBoards.count) {
					isShowingArchived = true
				}
			}

			ForEach(boardStore.listedBoards) { board in
				BoardListRow(
					board: board,
					rename: { renaming = Renaming(id: board.id, name: board.name) }
				)
			}
		}
	}

	var body: some View {
		NavigationStack {
			list
				.renameAlert("Rename Board", renaming: $renaming) { id, name in
					boardStore.rename(id, to: name)
				}
				.navigationDestination(isPresented: $isShowingArchived) {
					ArchivedBoardsView()
				}
				.overlay {
					if boardStore.boards.isEmpty {
						ContentUnavailableView(
							"No Boards",
							systemImage: "doc.text",
							description: Text("Anything you write on the Board tab is kept here.")
						)
					}
				}
				.toolbarTitleVire("Boards", "text.page.and.line.vertical.and.text.page")
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button(role: .close) {
							navigation.dismissSheet()
						}
					}

					ToolbarItem(placement: .topBarTrailing) {
						Button("New Board", systemImage: "square.and.pencil") {
							boardStore.newBoard()
							navigation.dismissSheet()
						}
						.buttonStyle(.glassProminent)
						.scrollEdgeEffectStyle(.soft, for: .all)
						.accessibilityIdentifier("boards.newBoard")
					}
				}
		}
	}
}

/// What's been archived. Opening one puts it on the canvas like any other, and it stays archived until it's brought back.
private struct ArchivedBoardsView: View {
	@Environment(BoardStore.self)
	private var boardStore

	var body: some View {
		List {
			ForEach(boardStore.archivedBoards) { board in
				BoardListRow(board: board)
			}
		}
		.overlay {
			if boardStore.archivedBoards.isEmpty {
				ContentUnavailableView("No Archived Boards", systemImage: "archivebox")
			}
		}
		.navigationTitle("Archived")
		.toolbarTitleDisplayMode(.inline)
	}
}

/// A board in a list, with its swipes and context menu
private struct BoardListRow: View {
	let board: Board

	/// Archived boards aren't renamed
	var rename: (() -> Void)?

	@Environment(NavigationManager.self)
	private var navigation

	@Environment(BoardStore.self)
	private var boardStore

	var body: some View {
		Button {
			boardStore.open(board.id)
			navigation.dismissSheet()
		} label: {
			BoardRow(
				board: board,
				isCurrent: board.id == boardStore.current.id,
				isPinned: boardStore.pinnedIDs.contains(board.id)
			)
		}
		.buttonStyle(.plain)
		.swipeActions {
			Button("Delete", systemImage: "trash", role: .destructive) {
				boardStore.delete([board.id])
			}

			ArchiveButton(isArchived: boardStore.archivedIDs.contains(board.id)) {
				boardStore.setArchived(!boardStore.archivedIDs.contains(board.id), board.id)
			}
		}
		.swipeActions(edge: .leading) {
			renameButton

			if !boardStore.archivedIDs.contains(board.id) {
				PinButton(isPinned: boardStore.pinnedIDs.contains(board.id)) {
					boardStore.setPinned(!boardStore.pinnedIDs.contains(board.id), board.id)
				}
			}
		}
		.contextMenu {
			renameButton

			BoardActions(board: board) {
				boardStore.delete([board.id])
			}
		}
	}

	@ViewBuilder
	private var renameButton: some View {
		if let rename {
			Button("Rename", systemImage: "pencil", action: rename)
				.tint(.orange)
		}
	}
}

/// Pin, archive and removing a board, for the canvas's menu and a board's context menu
struct BoardActions: View {
	let board: Board
	let remove: () -> Void

	@Environment(BoardStore.self)
	private var boardStore

	var body: some View {
		Section {
			// An archived board isn't in the list for a pin to do anything
			if !boardStore.archivedIDs.contains(board.id) {
				PinButton(isPinned: boardStore.pinnedIDs.contains(board.id)) {
					boardStore.setPinned(!boardStore.pinnedIDs.contains(board.id), board.id)
				}
				.accessibilityIdentifier("board.pin")
			}

			ArchiveButton(isArchived: boardStore.archivedIDs.contains(board.id)) {
				boardStore.setArchived(!boardStore.archivedIDs.contains(board.id), board.id)
			}
			.accessibilityIdentifier("board.archive")
		}

		Section {
			Button("Delete", systemImage: "trash", role: .destructive, action: remove)
				.accessibilityIdentifier("board.remove")
		}
	}
}

extension View {
	/// Asks before a board goes
	func boardRemovalDialog(_ board: Binding<Board?>) -> some View {
		modifier(BoardRemovalDialog(board: board))
	}
}

private struct BoardRemovalDialog: ViewModifier {
	@Binding var board: Board?

	@Environment(BoardStore.self)
	private var boardStore

	private var isShown: Binding<Bool> {
		Binding(
			get: { board != nil },
			set: { isShown in
				if !isShown {
					board = nil
				}
			}
		)
	}

	func body(content: Content) -> some View {
		content
			.confirmationDialog("Delete this board?", isPresented: isShown, titleVisibility: .visible, presenting: board) { board in
				Button("Delete", role: .destructive) {
					boardStore.delete([board.id])
				}
				.accessibilityIdentifier("boards.delete")
			} message: { _ in
				Text("This can't be undone")
			}
	}
}

struct BoardRow: View {
	let board: Board
	let isCurrent: Bool
	var isPinned = false

	var body: some View {
		HStack {
			VStack(alignment: .leading, spacing: 4) {
				Text(board.title)
					.font(.headline)
					.lineLimit(1)

				Text(board.modified, format: .relative(presentation: .named))
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}

			Spacer(minLength: 0)

			if isPinned {
				Image(systemName: "pin.fill")
					.font(.caption)
					.foregroundStyle(.secondary)
					.accessibilityLabel("Pinned")
			}

			if isCurrent {
				Image(systemName: "checkmark")
					.foregroundStyle(.tint)
					.accessibilityLabel("Open")
			}
		}
		.contentShape(Rectangle())
	}
}
