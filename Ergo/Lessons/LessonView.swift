//
//  LessonView.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Hosts one lesson. There's no back button: the toolbar's close is the only way out, and the lesson keeps its place.
struct LessonView: View {
	let lesson: Lesson

	@Environment(NavigationManager.self)
	private var navigation

	@Default(.behindTheWordsState) private var behindTheWords
	@Default(.fairPointState) private var fairPoint
	@Default(.biggerPictureState) private var biggerPicture

	/// On the summary, closing is what's left to do, so the button stands out
	private var isOnSummary: Bool {
		switch lesson {
			case .behindTheWords: behindTheWords.page == .summary
			case .fairPoint: fairPoint.page == .summary
			case .biggerPicture: biggerPicture.page == .summary
		}
	}

	var body: some View {
		content
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden()
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					if isOnSummary {
						closeButton
							.buttonStyle(.glassProminent)
					} else {
						closeButton
					}
				}
			}
	}

	private var closeButton: some View {
		Button("Close", systemImage: "xmark") {
			navigation.learnPath.removeAll()
		}
		.accessibilityIdentifier("learn.lesson.close")
	}

	@ViewBuilder
	private var content: some View {
		switch lesson {
			case .behindTheWords:
				BehindTheWordsLesson()
			case .fairPoint:
				FairPointLesson()
			case .biggerPicture:
				BiggerPictureLesson()
		}
	}
}

/// "Lesson 1: Deeper look"
func lessonTitle(_ lesson: Lesson, _ page: String) -> String {
	"Lesson \(lesson.number): \(page)"
}
