//
//  Toolbar+.swift
//  Ergo
//
//  Created by Adon Omeri on 1/11/2026.
//

import SwiftUI

extension View {
	func toolbarTitleItem() -> some View {
		modifier(ToolbarTitleItemModifier())
	}
}

private struct ToolbarTitleItemModifier: ViewModifier {
	@Environment(NavigationManager.self) private var navigation

	func body(content: Content) -> some View {
		content
			.toolbar {
				ToolbarTitleItem(
					openSettings: {
						navigation.presentSheet(.settings(id: "3refd"))
					}
				)
			}
	}
}

struct ToolbarTitleItem: ToolbarContent {
	let openSettings: () -> Void

	var body: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				openSettings()
			} label: {
				ToolbarTitleView()
			}
		}
		.visibilityPriority(.high)
		.sharedBackgroundVisibility(.hidden)
	}
}

struct ToolbarTitleView: View {
	var body: some View {
		Image("Ergo")
			.foregroundStyle(.accent)
	}
}

extension View {
	func toolbarTitleVire(_ title: String, _ symbol: String) -> some View {
		modifier(ToolbarTitleViewModifier(title: title, symbol: symbol))
	}
}

private struct ToolbarTitleViewModifier: ViewModifier {
	@Environment(NavigationManager.self) private var navigation

	let title: String
	let symbol: String

	func body(content: Content) -> some View {
		content
			.navigationTitle(title)
			.navigationBarTitleDisplayMode(.inline)
			.scrollEdgeEffectStyle(.soft, for: .all)
			.toolbar {
				ToolbarItem(placement: .title) {
					Label {
						Text(title)
					} icon: {
						if symbol.isEmpty {
							EmptyView()
						} else {
							Image(systemName: symbol)
								.foregroundStyle(.accent)
						}
					}
					.labelStyle(.titleAndIcon)
				}
			}
	}
}

extension View {
	/// A title that fades in under the navigation bar once the page has scrolled.
	func libraryDetailTitle(_ name: String, category: String, hasScrolled: Bool) -> some View {
		modifier(LibraryDetailTitleModifier(name: name, category: category, hasScrolled: hasScrolled))
	}
}

private struct LibraryDetailTitleModifier: ViewModifier {
	let name: String
	let category: String
	let hasScrolled: Bool

	func body(content: Content) -> some View {
		content
			.toolbar {
				ToolbarItem(placement: .title) {
					// Always there, so the bar gives it room: an item that starts out empty is never shown
					VStack {
						Text(name)
							.lineLimit(1)

						Text(category)
							.textCase(.uppercase)
							.font(.caption2)
							.foregroundStyle(.secondary)
					}
					.opacity(hasScrolled ? 1 : 0)
					.blur(radius: hasScrolled ? 0 : 6)
					.animation(.easeInOut(duration: 0.2), value: hasScrolled)
				}
			}
	}
}
