//
//  LessonSummaryPage.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import Defaults
import SwiftUI

/// Every lesson's last page: what it taught, and the Library entries behind it. Showing it finishes the lesson.
struct LessonSummaryPage<Extra: View>: View {
	let lesson: Lesson
	let takeaway: String

	/// Anything the lesson adds between the heading and the takeaway, like a score
	@ViewBuilder var extra: Extra

	@Environment(NavigationManager.self)
	private var navigation

	@Default(.lessonsFinished) private var finished

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 24) {
				Text("That's lesson \(lesson.number) done!")
					.font(.title3.bold())
					.frame(maxWidth: .infinity)

				extra

				section("Summary") {
					Text(takeaway)
						.font(.body)
						.padding()
						.frame(maxWidth: .infinity, alignment: .leading)
						.background(.tint.opacity(0.15), in: .rect(cornerRadius: 16))
				}

				section("Related") {
					ForEach(lesson.related, id: \.self) { link in
						relatedButton(link)
					}
				}
			}
			.padding()
		}
		.navigationTitle(lessonTitle(lesson, lesson.pageTitle))
		.onAppear {
			finished.insert(lesson)
		}
	}

	private func section(_ title: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(title)
				.font(.caption.weight(.semibold))
				.foregroundStyle(.secondary)
				.textCase(.uppercase)

			content()
		}
	}

	private func relatedButton(_ link: LessonLink) -> some View {
		Button {
			navigation.openLibraryEntry(category: link.category, id: link.id)
		} label: {
			HStack {
				Text(link.name)
				Spacer(minLength: 0)
				Image(systemName: "arrow.right")
			}
			.padding()
			.frame(maxWidth: .infinity)
			.background(.tint.opacity(0.15), in: .rect(cornerRadius: 16))
		}
		.buttonStyle(.plain)
		.accessibilityIdentifier("learn.related.\(link.id)")
	}
}

extension LessonSummaryPage where Extra == EmptyView {
	init(lesson: Lesson, takeaway: String) {
		self.init(lesson: lesson, takeaway: takeaway) {
			EmptyView()
		}
	}
}
