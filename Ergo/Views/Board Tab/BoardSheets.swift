//
//  BoardSheets.swift
//  Ergo
//
//  Created by Adon Omeri on 10/11/2026.
//

import Defaults
import SwiftUI

/// The sheets that belong to the Board tab. See `NavigationManager.boardSheet`.
nonisolated enum BoardSheet: Hashable, Identifiable, Codable, Defaults.Serializable {
	case boards

	var id: Self {
		self
	}
}

struct BoardSheetContent: View {
	let sheet: BoardSheet

	var body: some View {
		switch sheet {
			case .boards:
				BoardsSheet()
		}
	}
}
