//
//  BehindTheWordsContent.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Foundation

/// What a part of a passage does
nonisolated enum BehindTheWordsKind: String, Codable, Hashable, Sendable {
	case claim
	case reason
	case filler

	var name: String {
		switch self {
			case .claim: "Claim"
			case .reason: "Reason"
			case .filler: "Filler"
		}
	}
}

/// One numbered part of the post
nonisolated struct BehindTheWordsUnit: Identifiable, Hashable, Sendable {
	let number: Int
	let text: String
	let kind: BehindTheWordsKind
	/// Shown under its row when it's sorted wrongly
	let hint: String

	var id: Int {
		number
	}
}

/// A passage on page 3, and whether it gives a reason
nonisolated struct BehindTheWordsQuizItem: Identifiable, Hashable, Sendable {
	let id: Int
	let text: String
	let givesReason: Bool
	let explanation: String
}

/// Everything Behind the words says. Every answer is authored here.
nonisolated enum BehindTheWords {
	private static let reasonHint = "If this is true, does starting at 9 make more sense? Then it's a reason."

	static let units: [BehindTheWordsUnit] = [
		BehindTheWordsUnit(
			number: 1,
			text: "Nobody is talking about this.",
			kind: .filler,
			hint: "You could put this on any post. It doesn't tell you anything about school."
		),
		BehindTheWordsUnit(
			number: 2,
			text: "School should start at 9, not 8.",
			kind: .claim,
			hint: ""
		),
		BehindTheWordsUnit(
			number: 3,
			text: "Teenagers' body clocks run later, so most aren't properly awake at 8,",
			kind: .reason,
			hint: reasonHint
		),
		BehindTheWordsUnit(
			number: 4,
			text: "and one school that moved to 9 had far fewer late arrivals.",
			kind: .reason,
			hint: reasonHint
		),
		BehindTheWordsUnit(
			number: 5,
			text: "Experts agree.",
			kind: .filler,
			hint: "It sounds like a reason, but which experts, and where did they say it? Nobody's named, so there's nothing to check."
		),
		BehindTheWordsUnit(
			number: 6,
			text: "Wake up, people. 😴",
			kind: .filler,
			hint: "It tells you how to feel, not why to agree."
		),
	]

	/// The units question 2 sorts: everything but the claim
	static var sortable: [BehindTheWordsUnit] {
		units.filter { $0.kind != .claim }
	}

	/// The post as it's written
	static var passage: String {
		units.map(\.text).joined(separator: " ")
	}

	static var wordCount: Int {
		passage.split(whereSeparator: \.isWhitespace).count
	}

	/// "42 words · 1 claim · 2 reasons"
	static var countLine: String {
		let claims = units.filter { $0.kind == .claim }.count
		let reasons = units.filter { $0.kind == .reason }.count
		return "\(wordCount) words · \(claims) \(claims == 1 ? "claim" : "claims") · \(reasons) \(reasons == 1 ? "reason" : "reasons")"
	}

	static let claimHint = "Is this the thing the post wants you to agree with?"

	/// The skeleton's cards, in markdown: the claim, the reasons, and the filler that passes for a reason
	static let skeletonClaim = "**What it wants you to believe:** school should start at 9."
	static let skeletonReasons = "**Why:** teenagers' body clocks run later · one school had fewer late arrivals."
	static let surrogateNote = "**Looks like a reason, but isn't:** \"Experts agree.\" No expert is named, so there's nothing you can check. It's easy to miss, because it sounds just like proof. That's called a **proof surrogate**."

	static let quiz: [BehindTheWordsQuizItem] = [
		BehindTheWordsQuizItem(
			id: 0,
			text: "Our new formula is our best yet. You'll feel the difference from day one.",
			givesReason: false,
			explanation: "Two claims and no reason for either."
		),
		BehindTheWordsQuizItem(
			id: 1,
			text: "Bring a jacket. It drops to four degrees after dark.",
			givesReason: true,
			explanation: "This one is short and plain, with a claim and a reason."
		),
		BehindTheWordsQuizItem(
			id: 2,
			text: "At the end of the day, it is what it is, and what matters is that we keep moving forward together.",
			givesReason: false,
			explanation: "There isn't even a claim to disagree with."
		),
		BehindTheWordsQuizItem(
			id: 3,
			text: "This is the most important election of our lifetime, because the next government sets the emissions targets through 2040.",
			givesReason: true,
			explanation: "It sounds like hype, but it gives a reason. Whether the reason is true is a separate question."
		),
	]

	/// The line under the quiz score when the model on the device can't write one (`LessonScoreLine`)
	static func scoreLine(for score: Int) -> String {
		switch score {
			case 4: "Every one. You're already looking underneath."
			case 3: "Nearly all of them. The one you missed is worth another look."
			case 2: "Half. Some of these are meant to be tricky."
			default: "These are harder than they look. Try reading for the reason first."
		}
	}
}
