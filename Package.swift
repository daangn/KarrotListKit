// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "KarrotListKit",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "KarrotListKit",
      targets: ["KarrotListKit"]
    ),
    .library(
      name: "KarrotListKit5",
      targets: ["KarrotListKit5"],
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
    .target(
      name: "KarrotListKit5",
      dependencies: [
        "DifferenceKit",
      ]
    ),
  ]
)
