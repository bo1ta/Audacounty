// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AudioEngine",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "AudioEngine",
      targets: ["AudioEngine"]),
  ],
  dependencies: [
    .package(name: "Utility", path: "../Utility"),
    .package(url: "https://github.com/hmlongco/Factory", exact: "2.4.3"),
  ],
  targets: [
    .target(
      name: "AudioEngine",
      dependencies: ["Utility", "Factory"]
    ),
    .testTarget(
      name: "AudioEngineTests",
      dependencies: ["AudioEngine"]),
  ])
