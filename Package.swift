// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// IOSStarter — iOS Clean Architecture Starter Template
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import PackageDescription

let package = Package(
    name: "IOSStarter",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "IOSStarter",
            targets: ["IOSStarter"]
        )
    ],
    targets: [
        .target(
            name: "IOSStarter",
            path: "IOSStarter",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "IOSStarterTests",
            dependencies: ["IOSStarter"],
            path: "IOSStarterTests"
        )
    ]
)
