// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-enum-option-set",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "EnumOptionSet",
            targets: ["EnumOptionSet"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "600.0.0-latest"
        ),
    ],
    targets: [
        .macro(
            name: "EnumOptionSetMacros",
            dependencies: [
                .product(
                    name: "SwiftSyntaxMacros",
                    package: "swift-syntax"
                ),
                .product(
                    name: "SwiftCompilerPlugin",
                    package: "swift-syntax"
                )
            ]
        ),
        .target(
            name: "EnumOptionSet",
            dependencies: ["EnumOptionSetMacros"]
        ),
        .testTarget(
            name: "EnumOptionSetTests",
            dependencies: ["EnumOptionSet"]
        ),
    ]
)
