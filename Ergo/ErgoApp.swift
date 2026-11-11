//
//  ErgoApp.swift
//  Ergo
//
//  Created by Adon Omeri on 1/11/2026.
//

import AppIntents
import CoreSpotlight
import SwiftUI

@main
struct ErgoApp: App {
	@State private var navigation = NavigationManager()
	@State private var catalog = CatalogStore()
	@State private var boardStore: BoardStore
	@State private var scratchpadStore: ScratchpadStore

	@Environment(\.scenePhase)
	private var scenePhase

	init() {
		let navigation = NavigationManager()
		let catalog = CatalogStore()
		let boardStore = BoardStore()
		let scratchpadStore = ScratchpadStore()

		_navigation = State(initialValue: navigation)
		_catalog = State(initialValue: catalog)
		_boardStore = State(initialValue: boardStore)
		_scratchpadStore = State(initialValue: scratchpadStore)

		unsafe AppDependencyManager.shared.add(
			dependency: navigation
		)

		unsafe AppDependencyManager.shared.add(
			dependency: catalog
		)
	}

	var body: some Scene {
		WindowGroup {
			AppScene()
				.environment(catalog)
				.environment(navigation)
				.environment(boardStore)
				.environment(scratchpadStore)
				.onOpenURL { url in
					if let entry = ItemOfTheDayItem.entry(from: url) {
						navigation.openLibraryEntry(category: entry.category, id: entry.id)
					}
				}
				.task {
					StatusBadgeWindow.install()
					navigation.startup()

					do {
						try await catalog.load()
						try await LibraryIndexer.indexIfNeeded(from: catalog)
					} catch {
						print("Library indexing failed: \(error)")
					}
				}
		}
		.onChange(of: scenePhase) { _, phase in
			// Saves usually wait for a pause in typing, don't lose that pause to the app closing
			if phase != .active {
				boardStore.save()
				scratchpadStore.save()
			}
		}
	}
}

struct AppScene: View {
	var body: some View {
		ContentView()
	}
}
