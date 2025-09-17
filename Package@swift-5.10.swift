// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
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
  ],
  targets: [
    .target(
      name: "KarrotListKit",
      dependencies: [
        "DifferenceKit",
      ]
    ),
    .testTarget(
      name: "KarrotListKitTests",
      dependencies: ["KarrotListKit"]
    ),
  ]
)
