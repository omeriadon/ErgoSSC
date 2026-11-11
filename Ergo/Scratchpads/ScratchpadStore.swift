//
//  ScratchpadStore.swift
//  Ergo
//
//  Created by Adon Omeri on 6/11/2026.
//

import Defaults
import ErgoLogic
import SwiftUI

/// Every scratchpad, and which one the Logic tab's editor is showing. Shared so the list and the editor edit
/// the same scratchpad, and so is the letters sheet.
///
/// Every change goes through `current`, so it's saved after a pause.
@MainActor
@Observable
final class ScratchpadStore {
	// MARK: - scratchpads

	private(set) var scratchpads: [LogicScratchpad]

	/// Newest first
	var sortedScratchpads: [LogicScratchpad] {
		scratchpads.sorted { $0.modified > $1.modified }
	}

	// MARK: - current

	private(set) var currentID: LogicScratchpad.ID? {
		didSet {
			Defaults[.currentScratchpadID] = currentID
		}
	}

	/// Stays out of the list until something's written on it
	private var draft = LogicScratchpad()

	var current: LogicScratchpad {
		get {
			scratchpads.first { $0.id == currentID } ?? draft
		}
		set {
			var scratchpad = newValue
			scratchpad.modified = .now

			if let index = scratchpads.firstIndex(where: { $0.id == scratchpad.id }) {
				scratchpads[index] = scratchpad
			} else if scratchpad.isEmpty {
				draft = scratchpad
			} else {
				scratchpads.append(scratchpad)
				currentID = scratchpad.id
			}

			scheduleSave()
		}
	}

	@ObservationIgnored
	private var saveTask: Task<Void, Never>?

	init() {
		scratchpads = Defaults[.scratchpads]
		currentID = Defaults[.currentScratchpadID]
	}

	// MARK: - newScratchpad

	func newScratchpad() {
		discardCurrentIfEmpty()
		draft = LogicScratchpad()
		currentID = nil
	}

	// MARK: - open

	func open(_ id: LogicScratchpad.ID) {
		guard id != currentID else { return }
		discardCurrentIfEmpty()
		currentID = id
	}

	// MARK: - delete

	func delete(_ ids: Set<LogicScratchpad.ID>) {
		scratchpads.removeAll { ids.contains($0.id) }
		if let currentID, ids.contains(currentID) {
			newScratchpad()
		}
		save()
	}

	// MARK: - rename

	/// An empty name goes back to titling the scratchpad from what's written on it
	func rename(_ id: LogicScratchpad.ID, to name: String) {
		guard let index = scratchpads.firstIndex(where: { $0.id == id }) else { return }
		scratchpads[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
		scratchpads[index].modified = .now
		scheduleSave()
	}

	// MARK: - save

	/// Typing changes the scratchpad on every keystroke, so writes wait for a pause
	private func scheduleSave() {
		saveTask?.cancel()
		saveTask = Task {
			try? await Task.sleep(for: .seconds(1))
			guard !Task.isCancelled else { return }
			save()
		}
	}

	func save() {
		saveTask?.cancel()
		Defaults[.scratchpads] = scratchpads
	}

	/// For leaving the editor: a scratchpad that's been emptied goes, like a board does
	func discardCurrentIfEmpty() {
		guard let currentID, current.isEmpty else { return }
		scratchpads.removeAll { $0.id == currentID }
		self.currentID = nil
		draft = LogicScratchpad()
		save()
	}
}
