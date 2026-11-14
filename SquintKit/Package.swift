// swift-tools-version: 6.2

import PackageDescription

/// What the app builds on: the library
let package = Package(
	name: "SquintKit",
	platforms: [
		.iOS("27.0"),
		.macOS("27.0"),
	],
	products: [
		.library(name: "SquintCatalog", targets: ["SquintCatalog"]),
	],
	targets: [
		.target(name: "SquintCatalog", resources: [.process("Resources")]),
	],
	swiftLanguageModes: [.v6]
)
