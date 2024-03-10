// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "KarrotListKit",
  platforms: [.iOS(.v13)],
  products: [
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
      url: "https://github.com/apple/swift-docc-plugin.git",
      from: "1.3.0"
    ),
  ],
  targets: [
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
