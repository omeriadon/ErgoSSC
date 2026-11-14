//
//  NavigationManager.swift
//  Squint
//
//  Created by Adon Omeri on 1/11/2026.
//

import Defaults
import SwiftUI

@MainActor
@Observable
final class NavigationManager {
	// MARK: - selectedTab

	var selectedTab: AppTab = .learn {
		didSet {
			Defaults[.selectedTab] = selectedTab
		}
	}

	// MARK: - learnPath

	var learnPath: [LearnRoute] = [] {
		didSet {
			Defaults[.learnPath] = learnPath
		}
	}

	// MARK: - presentedSheet

	/// Over whichever tab is showing
	var presentedSheet: AppSheet? {
		didSet {
			Defaults[.presentedSheet] = presentedSheet
		}
	}

	// MARK: - presentSheet

	func presentSheet(_ sheet: AppSheet) {
		presentedSheet = sheet
	}

	// MARK: - dismissSheet

	/// Closes the sheet on screen
	func dismissSheet() {
		presentedSheet = nil
	}

	// MARK: - reveal

	/// Goes to a tab with nothing over it
	func reveal(_ tab: AppTab) {
		selectedTab = tab
		presentedSheet = nil
	}

	// MARK: - startup()

	func startup() {
		// The welcome sheet comes first until it's been closed once
		presentedSheet = Defaults[.hasSeenWelcome] ? Defaults[.presentedSheet] : .welcome
		selectedTab = Defaults[.selectedTab]
		learnPath = Defaults[.learnPath]
	}
}
