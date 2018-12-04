// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "FuzzCheckExample",
    products: [
        .library(name: "Graph", targets: ["Graph"]),
        .executable(name: "FuzzCheckExample", targets: ["FuzzCheckExample"])
    ],
    dependencies: [
        .package(url: "https://github.com/loiclec/FuzzCheck.git", .revision("e9ab914dab0caeb5c96f7c71b022a9ecf9cbb266"))
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
