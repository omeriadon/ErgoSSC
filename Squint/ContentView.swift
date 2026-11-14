//
//  ContentView.swift
//  Squint
//
//  Created by Adon Omeri on 1/11/2026.
//

import SwiftUI

struct ContentView: View {
	@Environment(NavigationManager.self)
	private var navigation

	var body: some View {
		@Bindable var router = navigation

		// The tabs read the selected tab themselves, so changing tabs doesn't redraw this
		AppTabs()
			.sheet(item: $router.presentedSheet) { sheet in
				AppSheetContent(sheet: sheet)
			}
			.fontDesign(.rounded)
	}
}

private struct AppSheetContent: View {
	let sheet: AppSheet

	var body: some View {
		switch sheet {
			case .welcome:
				WelcomeSheet()
		}
	}
}

/// The tab bar and its tabs. Selecting a tab only changes this view, not `ContentView`.
private struct AppTabs: View {
	@Environment(NavigationManager.self)
	private var navigation

	private var tabSelection: Binding<AppTab> {
		Binding(
			get: {
				navigation.selectedTab
			},
			set: { newValue in
				guard newValue != navigation.selectedTab else {
					return
				}

				navigation.selectedTab = newValue
			}
		)
	}

	private var learnPath: Binding<[LearnRoute]> {
		Binding(
			get: {
				navigation.learnPath
			},
			set: { newValue in
				navigation.learnPath = newValue
			}
		)
	}

	var body: some View {
		TabView(selection: tabSelection) {
			Tab(value: .learn) {
				NavigationStack(path: learnPath) {
					LearnTabView()
						.navigationDestination(for: LearnRoute.self) { route in
							switch route {
								case let .lesson(lesson):
									LessonView(lesson: lesson)
							}
						}
				}
			} label: {
				Label("Learn", systemImage: "text.magnifyingglass")
			}

			Tab(value: .library) {
				NavigationStack {
					LibraryFinderView()
						.toolbarTitleItem()
				}
			} label: {
				Label("Describe It", systemImage: "sparkle.magnifyingglass")
			}
		}
		.tabViewStyle(.tabBarOnly)
		.tabBarMinimizeBehavior(.onScrollDown)
		.tabBarHaptics()
		.tabTransition {}
	}
}

#Preview {
	@Previewable @State var thing = NavigationManager()

	ContentView()
		.environment(thing)
		.onAppear {
			thing.startup()
			thing.selectedTab = .library
		}
}
