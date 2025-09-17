// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "KarrotListKit",
  platforms: [.iOS(.v13), .macOS(.v10_15)],
  products: [
    .library(
      name: "KarrotListKit",
      targets: ["KarrotListKit"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", "509.0.0"..<"603.0.0"),
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
        "KarrotListKitMacros",
      ]
    ),
    .macro(
      name: "KarrotListKitMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
    .testTarget(
      name: "KarrotListKitTests",
      dependencies: ["KarrotListKit"]
    ),
    .testTarget(
      name: "KarrotListKitMacrosTests",
      dependencies: [
        "KarrotListKitMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
