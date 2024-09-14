// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BugItPackage",
    platforms: [
        .iOS(.v15) // Set the minimum iOS version to 15.0
    ],

    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BugItPackage",
            targets: ["BugItPackage"]),
    ],
    dependencies: [
        .package(name: "GoogleSignIn",url: "https://github.com/google/GoogleSignIn-iOS",  .upToNextMajor(from: "8.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
          name: "BugItPackage",
          dependencies:
            [
                .product(name: "GoogleSignIn", package: "GoogleSignIn"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn"),
            ]
        ),
        .testTarget(
            name: "BugItPackageTests",
            dependencies: ["BugItPackage"]),
    ]
)
