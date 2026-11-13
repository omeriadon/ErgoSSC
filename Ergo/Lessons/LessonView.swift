//
//  LessonView.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import SwiftUI

/// Hosts one lesson. There's no back button: the toolbar's close is the only way out, and the lesson keeps its place.
struct LessonView: View {
	let lesson: Lesson

	@Environment(NavigationManager.self)
	private var navigation

	var body: some View {
		content
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden()
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Close", systemImage: "xmark") {
						navigation.learnPath.removeAll()
					}
					.accessibilityIdentifier("learn.lesson.close")
				}
			}
	}

	@ViewBuilder
	private var content: some View {
		switch lesson {
			case .behindTheWords:
				BehindTheWordsLesson()
			case .fairPoint:
				FairPointLesson()
		}
	}
}

/// "Lesson 1: Deeper look"
func lessonTitle(_ lesson: Lesson, _ page: String) -> String {
	"Lesson \(lesson.number): \(page)"
}
