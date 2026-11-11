//
//  BoardStore.swift
//  Ergo
//
//  Created by Adon Omeri on 5/11/2026.
//

import Defaults
import ErgoLogic
import SwiftUI

/// Every board, and which one the Board tab is showing. Shared so the boards list
/// and the editor edit the same board.
///
/// Statements, links and sources are edited on the current board through the methods under "statements", "links" and "sources". Each
/// one bumps `modified` and goes through `current`, so it's saved after a pause.
@MainActor
@Observable
final class BoardStore {
	// MARK: - boards

	var boards: [Board]

	/// Newest first
	var sortedBoards: [Board] {
		boards.sorted { $0.modified > $1.modified }
	}

	/// What the list shows: pinned first, then newest first
	var listedBoards: [Board] {
		let listed = sortedBoards.filter { !archivedIDs.contains($0.id) }
		return listed.filter { pinnedIDs.contains($0.id) } + listed.filter { !pinnedIDs.contains($0.id) }
	}

	var archivedBoards: [Board] {
		sortedBoards.filter { archivedIDs.contains($0.id) }
	}

	var pinnedIDs: Set<Board.ID> {
		didSet {
			Defaults[.pinnedBoards] = pinnedIDs
		}
	}

	var archivedIDs: Set<Board.ID> {
		didSet {
			Defaults[.archivedBoards] = archivedIDs
		}
	}

	// MARK: - current

	var currentID: Board.ID? {
		didSet {
			Defaults[.currentBoardID] = currentID
		}
	}

	/// Stays out of the list until something's written on it
	var draft = Board()

	var current: Board {
		get {
			boards.first { $0.id == currentID } ?? draft
		}
		set {
			var board = newValue
			board.modified = .now

			if let index = boards.firstIndex(where: { $0.id == board.id }) {
				boards[index] = board
			} else if board.isEmpty {
				draft = board
			} else {
				boards.append(board)
				currentID = board.id
			}

			scheduleSave()
		}
	}

	@ObservationIgnored
	var saveTask: Task<Void, Never>?

	init() {
		boards = Defaults[.boards]
		currentID = Defaults[.currentBoardID]
		pinnedIDs = Defaults[.pinnedBoards]
		archivedIDs = Defaults[.archivedBoards]
	}

	// MARK: - newBoard

	func newBoard() {
		discardCurrentIfEmpty()
		draft = Board()
		currentID = nil
	}

	// MARK: - open

	func open(_ id: Board.ID) {
		guard id != currentID else { return }
		discardCurrentIfEmpty()
		currentID = id
	}

	// MARK: - delete

	func delete(_ ids: Set<Board.ID>) {
		boards.removeAll { ids.contains($0.id) }
		pinnedIDs.subtract(ids)
		archivedIDs.subtract(ids)
		if let currentID, ids.contains(currentID) {
			newBoard()
		}
		save()
	}

	// MARK: - pin and archive

	func setPinned(_ isPinned: Bool, _ id: Board.ID) {
		if isPinned {
			pinnedIDs.insert(id)
		} else {
			pinnedIDs.remove(id)
		}
	}

	/// Archiving the open board starts a new one, as deleting it does.
	func setArchived(_ isArchived: Bool, _ id: Board.ID) {
		guard isArchived else {
			archivedIDs.remove(id)
			return
		}
		archivedIDs.insert(id)
		pinnedIDs.remove(id)
		if id == currentID {
			newBoard()
		}
	}

	// MARK: - rename

	/// An empty name goes back to titling the board from what's written on it
	func rename(_ id: Board.ID, to name: String) {
		guard let index = boards.firstIndex(where: { $0.id == id }) else { return }
		boards[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
		boards[index].modified = .now
		scheduleSave()
	}

	// MARK: - save

	/// Typing changes the board on every keystroke, so writes wait for a pause
	func scheduleSave() {
		saveTask?.cancel()
		saveTask = Task {
			try? await Task.sleep(for: .seconds(1))
			guard !Task.isCancelled else { return }
			save()
		}
	}

	func save() {
		saveTask?.cancel()
		Defaults[.boards] = boards
	}

	func discardCurrentIfEmpty() {
		guard let currentID, current.isEmpty else { return }
		boards.removeAll { $0.id == currentID }
		save()
	}
}
