//
//  FairPointNote.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

extension View {
	/// A popover pointing at the bubble, which stays a popover on iPhone
	func fairPointNote(_ note: String?, isPresented: Binding<Bool>) -> some View {
		popover(isPresented: isPresented) {
			Text(LocalizedStringKey(note ?? ""))
				.font(.callout)
				.fixedSize(horizontal: false, vertical: true)
				.frame(width: 260, alignment: .leading)
				.padding()
				.presentationCompactAdaptation(.popover)
		}
	}
}

/// Which bubble's popover is showing. Only one at a time.
func fairPointNoteBinding(_ id: String, shown: Binding<String?>) -> Binding<Bool> {
	Binding(
		get: { shown.wrappedValue == id },
		set: { isShown in
			if isShown {
				shown.wrappedValue = id
			} else if shown.wrappedValue == id {
				shown.wrappedValue = nil
			}
		}
	)
}
