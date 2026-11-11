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

	var selectedTab: AppTab = .board {
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

	// MARK: - logicPath

	var logicPath: [LogicRoute] = [] {
		didSet {
			Defaults[.logicPath] = logicPath
		}
	}

	// MARK: - presentedSheet

	/// A sheet that doesn't belong to one tab. It's over whichever tab is showing.
	var presentedSheet: AppSheet? {
		didSet {
			Defaults[.presentedSheet] = presentedSheet
		}
	}

	// MARK: - Each tab's sheet

	// Each tab keeps its own, and it only shows while that tab does. Leaving a tab takes its sheet away, and coming back
	// brings it back.

	var boardSheet: BoardSheet? {
		didSet {
			Defaults[.boardSheet] = boardSheet
		}
	}

	var logicSheet: LogicSheet? {
		didSet {
			Defaults[.logicSheet] = logicSheet
		}
	}

	// MARK: - visibleSheet

	/// One presenter shows all of them, so going from one to another is SwiftUI swapping a sheet, which it does reliably.
	/// Separate presenters would need one to finish going away before the next could appear.
	var visibleSheet: VisibleSheet? {
		get {
			if let presentedSheet {
				return .app(presentedSheet)
			}
			return switch selectedTab {
				case .board: boardSheet.map(VisibleSheet.board)
				case .logic: logicSheet.map(VisibleSheet.logic)
				case .library: nil
			}
		}
		set {
			if newValue == nil {
				dismissSheet()
			}
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

	func presentSheet(_ sheet: BoardSheet) {
		selectedTab = .board
		boardSheet = sheet
	}

	func presentSheet(_ sheet: LogicSheet) {
		selectedTab = .logic
		logicSheet = sheet
	}

	// MARK: - dismissSheet

	/// Closes the sheet on screen
	func dismissSheet() {
		if presentedSheet != nil {
			presentedSheet = nil
			return
		}
		switch selectedTab {
			case .board: boardSheet = nil
			case .logic: logicSheet = nil
			case .library: break
		}
	}

	// MARK: - reveal

	/// Goes to a tab with nothing over it. Other tabs keep their sheets for when they're next opened.
	func reveal(_ tab: AppTab) {
		selectedTab = tab
		presentedSheet = nil
		switch tab {
			case .board: boardSheet = nil
			case .logic: logicSheet = nil
			case .library: break
		}
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
			case .board:
				break
			case .logic:
				logicPath.removeAll()
			case .library:
				libraryPath.removeAll()
		}
	}

	// MARK: - startup()

	func startup() {
		presentedSheet = Defaults[.presentedSheet]
		boardSheet = Defaults[.boardSheet]
		logicSheet = Defaults[.logicSheet]
		selectedTab = Defaults[.selectedTab]
		libraryPath = Defaults[.libraryPath]
		logicPath = Defaults[.logicPath]
	}
}
