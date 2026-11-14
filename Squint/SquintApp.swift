//
//  SquintApp.swift
//  Squint
//
//  Created by Adon Omeri on 1/11/2026.
//

import SwiftUI

@main
struct SquintApp: App {
	@State private var navigation = NavigationManager()
	@State private var catalog = CatalogStore()

	var body: some Scene {
		WindowGroup {
			AppScene()
				.environment(catalog)
				.environment(navigation)
				.task {
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
