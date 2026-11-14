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

/// One numbered part of the forum reply
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

/// Everything lesson 1 says. Every answer is authored here.
nonisolated enum BehindTheWords {
	static let threadTitle = "Best coffee near the station?"

	private static let reasonHint = "If this claim is true, is Little Bird a better café?"

	static let units: [BehindTheWordsUnit] = [
		BehindTheWordsUnit(
			number: 1,
			text: "Honestly, life's too short for bad coffee.",
			kind: .filler,
			hint: "This is of every café. It doesn't tell you anything about this one."
		),
		BehindTheWordsUnit(
			number: 2,
			text: "If you're anywhere near the station, go to Little Bird.",
			kind: .claim,
			hint: ""
		),
		BehindTheWordsUnit(number: 3, text: "A flat white is $4.50,", kind: .reason, hint: reasonHint),
		BehindTheWordsUnit(number: 4, text: "they roast their own beans every morning,", kind: .reason, hint: reasonHint),
		BehindTheWordsUnit(number: 5, text: "and it's the only place round here open before 7.", kind: .reason, hint: reasonHint),
		BehindTheWordsUnit(
			number: 6,
			text: "Trust me, you'll thank me later.",
			kind: .filler,
			hint: "It asks you to trust it instead of giving you a reason to."
		),
	]

	/// The units question 2 sorts: everything but the claim
	static var sortable: [BehindTheWordsUnit] {
		units.filter { $0.kind != .claim }
	}

	/// The reply as it's posted
	static var passage: String {
		units.map(\.text).joined(separator: " ")
	}

	static var wordCount: Int {
		passage.split(whereSeparator: \.isWhitespace).count
	}

	/// "45 words · 1 claim · 3 reasons"
	static var countLine: String {
		let claims = units.filter { $0.kind == .claim }.count
		let reasons = units.filter { $0.kind == .reason }.count
		return "\(wordCount) words · \(claims) \(claims == 1 ? "claim" : "claims") · \(reasons) \(reasons == 1 ? "reason" : "reasons")"
	}

	static let claimHint = "Does this actually tell you to do something?"

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
