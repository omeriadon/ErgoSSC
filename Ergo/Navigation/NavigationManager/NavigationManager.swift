//
//  NavigationManager.swift
//  Ergo
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

	// MARK: - libraryPath

	var libraryPath: [LibraryRoute] = [] {
		didSet {
			Defaults[.libraryPath] = libraryPath
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

	// MARK: - listStates

	let listStates: [LibraryContent: LibraryListState] = Dictionary(
		uniqueKeysWithValues: LibraryContent.allCases.map { category in
			(category, LibraryListState())
		}
	)

	// MARK: - symbolFilters

	var symbolFilters: [SymbolSearchToken] = []

	// MARK: - libraryTagFilters

	var libraryTagFilters: [LibraryContent: [String]] = [:]

	// MARK: - libraryGeneralSearchText

	var libraryGeneralSearchText = "" {
		didSet {
			Defaults[.libraryGeneralSearchText] = libraryGeneralSearchText
		}
	}

	// MARK: - openLibrary

	func openLibrary(_ route: LibraryRoute) {
		selectedTab = .library
		libraryPath.append(route)
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

	// MARK: - openLibraryEntry

	func openLibraryEntry(category: LibraryContent, id: String) {
		// A sheet left open would hide the page, so the link would look like it did nothing
		reveal(.library)

		let route = LibraryRoute.detail(category: category, id: id)
		if libraryPath.last != route {
			libraryPath.append(route)
		}
	}

	// MARK: - reset()

	func reset(_ tab: AppTab) {
		switch tab {
			case .learn:
				learnPath.removeAll()
			case .library:
				libraryPath.removeAll()
		}
	}

	// MARK: - startup()

	func startup() {
		presentedSheet = Defaults[.presentedSheet]
		selectedTab = Defaults[.selectedTab]
		libraryPath = Defaults[.libraryPath]
		learnPath = Defaults[.learnPath]
	}
}
