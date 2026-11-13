//
//  Library Navigation.swift
//  Ergo
//
//  Created by Adon Omeri on 2/11/2026.
//

import Defaults
import ErgoCatalog
import Foundation
import SwiftUI

/// all the content middle views library can go to
nonisolated enum LibraryContent: String, Hashable, CaseIterable, Codable, Sendable, Defaults.Serializable, LosslessStringConvertible {
	var description: String {
		rawValue.capitalized
	}

	init?(_ description: String) {
		self.init(rawValue: description.lowercased())
	}

	case biases
	case fallacies

	var symbol: String {
		switch self {
			case .biases:
				"distribute.vertical.center"
			case .fallacies:
				"repeat.badge.xmark"
		}
	}

	var title: String {
		rawValue.capitalized
	}

	var themeColor: Color {
		CategoryTheme.color(for: self)
	}
}

/// the actual library route, middle plus detail
nonisolated enum LibraryRoute: Hashable, Codable, Defaults.Serializable {
	case category(LibraryContent)
	case detail(category: LibraryContent, id: String)

	case biases(filter: BiasTag)
	case fallacies(filter: FallacyTag)

	case finder

	var listCategory: LibraryContent? {
		switch self {
			case let .category(category):
				category

			case .biases:
				.biases

			case .fallacies:
				.fallacies

			case .detail, .finder:
				nil
		}
	}
}
