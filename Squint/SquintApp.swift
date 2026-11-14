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

	var body: some Scene {
		WindowGroup {
			AppScene()
				.environment(navigation)
				.task {
					navigation.startup()
				}
		}
	}
}

struct AppScene: View {
	var body: some View {
		ContentView()
	}
}
