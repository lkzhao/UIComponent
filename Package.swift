// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "CollectionKit3",
	platforms: [
		.iOS(.v13),
	],
	products: [
		.library(
			name: "CollectionKit3",
			targets: ["CollectionKit3"]
		),
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		// .package(url: /* package url */, from: "1.0.0"),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages which this package depends on.
		.target(
			name: "CollectionKit3",
			dependencies: []
		),
		.testTarget(
			name: "CollectionKit3Tests",
			dependencies: ["CollectionKit3"]
		),
	]
)
