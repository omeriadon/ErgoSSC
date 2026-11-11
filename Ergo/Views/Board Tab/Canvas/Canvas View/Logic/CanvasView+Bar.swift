//
//  CanvasView+Bar.swift
//  Ergo
//
//  Created by Adon Omeri on 8/11/2026.
//

import ErgoLogic
import SwiftUI

extension CanvasView {
	var barMode: CanvasBarMode {
		if let activePick {
			return .picking(prompt(for: activePick))
		}
		return switch activeSelection {
			case .statement: .statement
			case .link: .link
			case let .source(id): .source(isLink: board.source(id)?.link != nil)
			case nil: .idle
		}
	}

	var barActions: CanvasBarActions {
		CanvasBarActions(
			add: addStatement,
			addText: { sourceSheet = .newText },
			addLink: { sourceSheet = .newLink },
			edit: {
				if case let .statement(id)? = activeSelection {
					edit(id)
				}
			},
			openSource: {
				if case let .source(id)? = activeSelection {
					open(id)
				}
			},
			delete: {
				switch activeSelection {
					case let .statement(id)?: delete(id)
					case let .link(id)?: deleteLink(id)
					case let .source(id)?: deleteSource(id)
					case nil: break
				}
			},
			cancelPick: { pick = nil }
		)
	}
}
