// swift-tools-version:6.2
import PackageDescription

let package = Package(
	name: "Defaults",
	platforms: [
		.macOS(.v11),
		.iOS(.v14),
		.tvOS(.v14),
		.watchOS(.v9),
		.visionOS(.v1),
	],
	products: [
		.library(
			name: "Defaults",
			targets: [
				"Defaults",
			]
		),
	],
	// ErgoSSC: the macros and their swift-syntax dependency are cut, since the app doesn't use them and nothing may
	// need the network
	targets: [
		.target(
			name: "Defaults",
			resources: [
				.copy("PrivacyInfo.xcprivacy"),
			],
			swiftSettings: [
				.swiftLanguageMode(.v5),
			]
		),
		.testTarget(
			name: "DefaultsTests",
			dependencies: [
				"Defaults",
			],
			swiftSettings: [
				.swiftLanguageMode(.v5),
			]
		),
	]
)
