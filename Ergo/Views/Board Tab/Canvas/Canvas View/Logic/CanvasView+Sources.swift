//
//  CanvasView+Sources.swift
//  Ergo
//
//  Created by Adon Omeri on 8/11/2026.
//

import ErgoLogic
import SwiftUI

extension CanvasView {
	// MARK: - Sources

	/// A source can't be the answer to a pick, so tapping one just ends it
	func selectSource(_ id: BoardSource.ID) {
		pick = nil
		selection = .source(id)
	}

	/// Links always go to the browser, never a view in the app. Text opens its editor.
	func open(_ id: BoardSource.ID) {
		pick = nil
		selection = .source(id)
		guard let source = board.source(id) else { return }

		if let link = source.link {
			if link.isWebLink {
				UIApplication.shared.open(link)
			}
		} else {
			sourceSheet = .edit(id)
		}
	}

	func sourceDragStarted(_ id: BoardSource.ID) {
		pick = nil
		selection = .source(id)
		dragBefore = history.snapshot()
	}

	func sourceMoved(_ id: BoardSource.ID, to position: CanvasPoint) {
		boardStore.moveSource(id: id, to: position)
		history.register(dragBefore, name: "Move Source")
		dragBefore = nil
	}

	func nudgeSource(_ id: BoardSource.ID, columns: Int, rows: Int) {
		guard let source = board.source(id) else { return }
		let target = CanvasGrid.snapped(CanvasPoint(
			x: source.position.x + Double(columns) * CanvasGrid.step,
			y: source.position.y + Double(rows) * CanvasGrid.step
		))
		history.perform("Move Source") {
			boardStore.moveSource(id: id, to: target)
		}
	}

	func deleteSource(_ id: BoardSource.ID) {
		history.perform("Delete Source") {
			withAnimation(motion) {
				boardStore.deleteSource(id: id)
			}
		}
	}

	/// A new source where the person is looking
	func addSource(_ content: BoardSource.Content) {
		history.perform("Add Source") {
			withAnimation(motion) {
				let id = boardStore.addSource(content, at: freeSpot(near: viewCentre))
				selection = .source(id)
			}
		}
		if keepsFitting, !canvasBoard.hasBeenMoved {
			fit(animated: true)
		}
		keepsFitting = false
	}

	func sourceSheet(for sheet: SourceSheet) -> CanvasSourceSheet {
		CanvasSourceSheet(
			sheet: sheet,
			source: sheet.sourceID.flatMap { board.source($0) },
			add: addSource,
			update: { id, content in
				boardStore.updateSource(id, content: content)
			}
		)
	}
}
