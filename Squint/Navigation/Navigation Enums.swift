//
//  Navigation Enums.swift
//  Squint
//
//  Created by Adon Omeri on 1/11/2026.
//

import Defaults
import SwiftUI

/// The root tabs
enum AppTab: String, Hashable, Codable, Defaults.Serializable {
	case learn
	case library
}

/// Pushed on the Learn tab's list
nonisolated enum LearnRoute: Hashable, Codable, Defaults.Serializable {
	case lesson(Lesson)
}

/// The sheets, shown over whichever tab is selected
nonisolated enum AppSheet: Hashable, Identifiable, Codable, Defaults.Serializable {
	/// The first time the app opens
	case welcome

	var id: Self {
		self
	}
}
