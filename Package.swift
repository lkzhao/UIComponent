// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "UIComponent",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(
      name: "UIComponent",
      targets: ["UIComponent"]
    )
  ],
  dependencies: [
     .package(url: "https://github.com/lkzhao/BaseToolbox", from: "0.0.1"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "UIComponent",
      dependencies: ["BaseToolbox"]
    ),
    .testTarget(
      name: "UIComponentTests",
      dependencies: ["UIComponent"]
    ),
  ]
)
