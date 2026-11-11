// swift-tools-version: 6.2

import PackageDescription

/// What the app builds on: the logic checker and the library
let package = Package(
	name: "ErgoKit",
	platforms: [
		.iOS("27.0"),
		.macOS("27.0"),
	],
	products: [
		.library(name: "ErgoLogic", targets: ["ErgoLogic"]),
		.library(name: "ErgoCatalog", targets: ["ErgoCatalog"]),
	],
	targets: [
		.target(name: "ErgoLogic"),
		.target(name: "ErgoCatalog", resources: [.process("Resources")]),

		.testTarget(name: "ErgoLogicTests", dependencies: ["ErgoLogic"]),
	],
	swiftLanguageModes: [.v6]
)
