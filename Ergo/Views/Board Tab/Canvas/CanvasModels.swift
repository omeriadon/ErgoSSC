//
//  CanvasModels.swift
//  Ergo
//
//  Created by Adon Omeri on 6/11/2026.
//

import ErgoLogic

/// What one box shows. Compared before its SwiftUI is touched, so a box only redraws when this changes.
struct CanvasBoxModel: Equatable {
	let statement: Statement
	let relations: BoxRelations
	let appearance: BoxAppearance

	/// What's being searched for, to mark in the text. A hosted box can't read it from the environment.
	var findHighlight: String?
}

/// What one source shows, compared the same way
struct CanvasSourceModel: Equatable {
	let source: BoardSource
	let appearance: BoxAppearance
	var findHighlight: String?
}

/// A source and the cards in its region. Where they are is read from the views, so the shape follows a drag.
struct CanvasRegionModel: Equatable {
	let source: BoardSource.ID
	let members: [Statement.ID]
}
