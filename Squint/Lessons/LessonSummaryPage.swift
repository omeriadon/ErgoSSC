//
//  LessonSummaryPage.swift
//  Squint
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
						.background(.background.secondary, in: .rect(cornerRadius: 16))
				}

				section("Related") {
					ForEach(lesson.related, id: \.self) { link in
						relatedButton(link)
					}
				}
			}
			.padding()
			.padding(.top, 24)
		}
		.background {
			LessonSummaryBackground(tint: lesson.tint)
				.ignoresSafeArea()
		}
		.navigationTitle(lessonTitle(lesson, lesson.title))
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
			.background(.background.secondary, in: .rect(cornerRadius: 16))
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

/// The lesson's colour, dithered faintly behind the summary
private struct LessonSummaryBackground: View {
	let tint: Color

	@Environment(\.self) private var environment
	@Environment(\.colorScheme) private var colorScheme

	var body: some View {
		DitherView(configuration: configuration)
	}

	private var configuration: DitherConfiguration {
		let color = tint.resolve(in: environment)
		let dot = SIMD3(color.red, color.green, color.blue)
		var configuration = detailViewConf
		configuration.palette = [dot, dot]
		configuration.transparent = true
		configuration.opacity = colorScheme == .dark ? 0.35 : 0.2
		return configuration
	}
}
