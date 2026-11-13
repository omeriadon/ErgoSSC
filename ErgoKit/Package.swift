// swift-tools-version: 6.2

import PackageDescription

/// What the app builds on: the library
let package = Package(
	name: "ErgoKit",
	platforms: [
		.iOS("27.0"),
		.macOS("27.0"),
	],
	products: [
		.library(name: "ErgoCatalog", targets: ["ErgoCatalog"]),
	],
	targets: [
		.target(name: "ErgoCatalog", resources: [.process("Resources")]),
	],
	swiftLanguageModes: [.v6]
)
