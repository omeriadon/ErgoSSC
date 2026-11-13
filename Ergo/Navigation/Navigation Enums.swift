//
//  Navigation Enums.swift
//  Ergo
//
//  Created by Adon Omeri on 1/11/2026.
//

import Defaults
import SwiftUI

/// The root tabs
enum AppTab: String, Hashable, Codable, Defaults.Serializable {
	case learn
	case logic
	case library
}

/// Pushed on the Logic tab's list. The editor shows `ScratchpadStore.current`, so the route needs no id.
nonisolated enum LogicRoute: Hashable, Codable, Defaults.Serializable {
	case scratchpad
}

/// Pushed on the Learn tab's list
nonisolated enum LearnRoute: Hashable, Codable, Defaults.Serializable {
	case lesson(Lesson)
}

/// The sheets that don't belong to one tab. A tab's own are in `LogicSheet`.
nonisolated enum AppSheet: Hashable, Identifiable, Codable, Defaults.Serializable {
	case scanner
	case paste
	case result(id: String)

	case settings(id: String)

	var id: Self {
		self
	}
}

/// The one sheet on screen, whichever of the app's or a tab's it is
nonisolated enum VisibleSheet: Hashable, Identifiable {
	case app(AppSheet)
	case logic(LogicSheet)

	var id: Self {
		self
	}
}
