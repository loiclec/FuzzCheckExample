// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "FuzzCheckExample",
    products: [
        .library(name: "Graph", targets: ["Graph"]),
        .executable(name: "FuzzCheckExample", targets: ["FuzzCheckExample"])
    ],
    dependencies: [
        .package(path: "../FuzzCheck")
    ],
    targets: [
        .target(name: "FuzzCheckExample", dependencies: [
            "FuzzCheck",
            "FuzzCheckTool", 
            "GraphFuzzerInputGenerator", 
            "Graph"
        ]),
        .target(name: "GraphFuzzerInputGenerator", dependencies: ["FuzzCheck", "Graph"]),
        .target(name: "Graph", dependencies: [])
    ],
    fuzzedTargets: [
        "FuzzCheckExample",
        "Graph"
    ]
)
