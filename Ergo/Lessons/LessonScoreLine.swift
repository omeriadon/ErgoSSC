//
//  LessonScoreLine.swift
//  Ergo
//
//  Created by Adon Omeri on 13/11/2026.
//

import FoundationModels
import SwiftUI

/// One quiz question, as the model is told it
nonisolated struct LessonQuizResult: Sendable {
	/// What was shown: the passage, headline or claim
	let question: String
	/// The right answer, in words, like "cherry-picked"
	let answer: String
	let gotRight: Bool
}

/// The line under a quiz score. The model on the device writes it from what was right and wrong, and only ever writes
/// around the score: it never decides it. Without the model, or if it fails, the lesson's own line is shown.
struct LessonScoreLine: View {
	let lesson: Lesson
	let results: [LessonQuizResult]
	/// The lesson's own line for this score
	let fallback: String

	@State private var written = ""
	@State private var isWriting: Bool

	init(lesson: Lesson, results: [LessonQuizResult], fallback: String) {
		self.lesson = lesson
		self.results = results
		self.fallback = fallback
		_isWriting = State(initialValue: SystemLanguageModel.default.isAvailable)
	}

	var body: some View {
		ZStack {
			if isWriting, written.isEmpty {
				ProgressView()
					.transition(.opacity)
			} else {
				Text(written.isEmpty ? fallback : written)
					.transition(.opacity)
			}
		}
		.font(.body)
		.multilineTextAlignment(.center)
		.foregroundStyle(.secondary)
		.fixedSize(horizontal: false, vertical: true)
		.frame(minHeight: 44)
		.animation(.smooth(duration: 0.3), value: written.isEmpty)
		.task {
			await write()
		}
	}

	private func write() async {
		guard isWriting else { return }
		defer {
			isWriting = false
		}

		do {
			let session = LanguageModelSession(instructions: Self.instructions)
			for try await snapshot in session.streamResponse(to: prompt, options: Self.options) {
				written = snapshot.content
			}
		} catch {
			// Whatever was written before it stopped is kept, and with nothing written the lesson's own line shows
		}
	}

	// MARK: - What the model is told

	/// Greedy, so the same results always get the same line
	private static let options = GenerationOptions(samplingMode: .greedy)

	private static let instructions = """
	You write the short line shown under someone's score after a quiz in a lesson. Talk to them directly, as "you", \
	in plain, warm and friendly language, like a kind teacher. Write one or two short sentences, under 30 words in all.
	Don't repeat the score as a number. If they missed any, say briefly what the one they missed was about and what to \
	look for next time, without making them feel bad. If they got every one right, say what they're already doing well.
	No emoji, no markdown, and at most one exclamation mark.
	"""

	private var prompt: String {
		let right = results.filter(\.gotRight).count
		var lines = [
			"Lesson: \(lesson.title), about \(lesson.topics.joined(separator: ", ")).",
			"Score: \(right) of \(results.count).",
			"Questions:",
		]
		for (index, result) in results.enumerated() {
			let outcome = result.gotRight ? "They got it right." : "They got it wrong."
			lines.append("\(index + 1). \"\(result.question)\" The answer: \(result.answer). \(outcome)")
		}
		return lines.joined(separator: "\n")
	}
}
