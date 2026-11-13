//
//  ErgoApp.swift
//  Ergo
//
//  Created by Adon Omeri on 1/11/2026.
//

import SwiftUI

@main
struct ErgoApp: App {
	@State private var navigation = NavigationManager()
	@State private var catalog = CatalogStore()

	var body: some Scene {
		WindowGroup {
			AppScene()
				.environment(catalog)
				.environment(navigation)
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
					} catch {
						print("Library loading failed: \(error)")
					}
				}
		}
	}
}

struct AppScene: View {
	var body: some View {
		ContentView()
	}
}
