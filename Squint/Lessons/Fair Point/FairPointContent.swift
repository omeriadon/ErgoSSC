//
//  FairPointContent.swift
//  Squint
//
//  Created by Adon Omeri on 13/11/2026.
//

import Foundation

/// Who sent a message: blue on the right, or grey on the left
nonisolated enum ChatSender: Hashable, Sendable {
	case you
	case contact
}

/// One message in a conversation, and what its popover says
nonisolated struct ChatMessage: Identifiable, Hashable, Sendable {
	let id: String
	let sender: ChatSender
	let text: String
	/// Markdown, shown in a popover on the bubble
	var note: String?
	var isFair = true
}

/// A whole conversation with one person
nonisolated struct ChatThread: Hashable, Sendable {
	let name: String
	let messages: [ChatMessage]

	/// Their messages that have a popover
	var notedMessages: [ChatMessage] {
		messages.filter { $0.sender == .contact && $0.note != nil }
	}
}

/// A row in the inbox
nonisolated struct InboxRow: Identifiable, Hashable, Sendable {
	let name: String
	let preview: String
	let time: String

	var id: String {
		name
	}
}

/// Everything lesson 2 says. Every answer is authored here.
nonisolated enum FairPoint {
	static let sam = ChatThread(
		name: "Sam",
		messages: [
			ChatMessage(
				id: "sam.friday",
				sender: .contact,
				text: "are you coming friday?? 🎸",
				note: "Just a question. Nothing to check here."
			),
			ChatMessage(id: "sam.exam", sender: .you, text: "can't, exam on monday 😩"),
			ChatMessage(
				id: "sam.uni",
				sender: .contact,
				text: "so uni matters more than your friends now?",
				note: "You said you have an exam, not that uni matters more. Sam's answering something you didn't say. That's called a **straw man**.",
				isFair: false
			),
			ChatMessage(id: "sam.study", sender: .you, text: "no, I just need to study"),
			ChatMessage(
				id: "sam.boring",
				sender: .contact,
				text: "you've been so boring lately honestly",
				note: "This is about you, not about the exam. That's called **ad hominem**.",
				isFair: false
			),
			ChatMessage(
				id: "sam.either",
				sender: .contact,
				text: "either you come or you've just given up on having fun",
				note: "This message implies there's only two options, when theres more. That's a **false dilemma**.",
				isFair: false
			),
			ChatMessage(
				id: "sam.sorry",
				sender: .contact,
				text: "alright, what if you study all weekend and just come for the first hour?",
				note: "This one's fair. Sam's answering your actual reason, and finding a way to do both."
			),
		]
	)

	static let leo = ChatThread(
		name: "Leo",
		messages: [
			ChatMessage(id: "leo.ask", sender: .you, text: "can you walk Biscuit tonight? I've got a shift"),
			ChatMessage(
				id: "leo.everything",
				sender: .contact,
				text: "so I have to do everything in this house now?",
				note: "You asked about tonight, not everything. That's a **straw man**.",
				isFair: false
			),
			ChatMessage(
				id: "leo.walked",
				sender: .contact,
				text: "I walked him yesterday and the day before",
				note: "This one's fair. Leo has a point: they did walk him twice."
			),
			ChatMessage(
				id: "leo.either",
				sender: .contact,
				text: "either you walk him or he doesn't get walked",
				note: "Another **false dilemma**, Leo implies here that theres only two possible options, when there's more.",
				isFair: false
			),
			ChatMessage(
				id: "leo.feed",
				sender: .contact,
				text: "says the person who forgot to feed him last week",
				note: "Here Leo responds to you, instead of your argument. That's **ad hominem**.",
				isFair: false
			),
		]
	)

	/// The inbox that scrolls by on page 1. It lands on Sam.
	static let inbox: [InboxRow] = [
		InboxRow(name: "Mum", preview: "dinner's at 7, don't be late", time: "6:12 pm"),
		InboxRow(name: "Jess", preview: "lol did you see that", time: "5:48 pm"),
		InboxRow(name: "Football group", preview: "training moved to thursday", time: "4:30 pm"),
		InboxRow(name: "Leo", preview: "where's the charger", time: "3:05 pm"),
		InboxRow(name: "Sam", preview: "ok sorry. what if you study all weekend and just come for the first hour?", time: "2:17 pm"),
		InboxRow(name: "Dentist", preview: "Reminder: your appointment is on…", time: "Yesterday"),
	]

	static let landingRow = "Sam"

	static let takeaway = "When people get frustrated, they sometimes change what you said, make it about you, or act like there are only two choices. Usually they don't mean to, and everyone does it. Once you can spot it, it's easier to get back to what you were actually talking about."
}
