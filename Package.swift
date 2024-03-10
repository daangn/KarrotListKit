// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "KarrotListKit",
  platforms: [.iOS(.v13)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "KarrotListKit",
      targets: ["KarrotListKit"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/ra1028/DifferenceKit.git",
      .upToNextMajor(from: "1.0.0")
    ),
    .package(
      url: "https://github.com/devxoul/Then.git",
      .upToNextMajor(from: "3.0.0")
    ),
    .package(
      url: "https://github.com/apple/swift-docc-plugin",
      from: "1.3.0"
    ),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "KarrotListKit",
      dependencies: [
        "DifferenceKit",
        "Then",
      ]
    ),
    .testTarget(
      name: "KarrotListKitTests",
      dependencies: ["KarrotListKit"]
    ),
  ]
)
