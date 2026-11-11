//
//  SettingsView.swift
//  Ergo
//
//  Created by Adon Omeri on 4/11/2026.
//

import SwiftUI

struct SettingsView: View {
	@Environment(NavigationManager.self)
	private var navigation

	var body: some View {
		NavigationStack {
			Form {
				NavigationLink {
					UISettingsView()
				} label: {
					Label("UI", systemImage: "app.background.dotted")
				}

				Section {
					NavigationLink {
						AboutView()
					} label: {
						Label("About Ergo", image: "Ergo")
					}
				}
			}
			.tint(.accent)
			.toolbarTitleVire("Settings", "gearshape")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button(role: .close) {
						navigation.dismissSheet()
					}
				}
			}
		}
	}
}

#Preview {
	SettingsView()
		.environment(NavigationManager())
}
