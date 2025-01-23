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
  targets: [
    .target(
      name: "AudioEngine"),
    .testTarget(
      name: "AudioEngineTests",
      dependencies: ["AudioEngine"]),
  ])
