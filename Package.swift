// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-server-benchmarks",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.23.0")),
    ],
    targets: [
        .target(
            name: "Helpers"
        ),
        .executableTarget(
            name: "SwiftServerBenchmarks",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                .target(name: "Helpers"),
            ],
            path: "Benchmarks/SwiftServerBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        ),
    ]
)
