// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "FuzzTestExample",
    products: [
        .library(name: "Graph", targets: ["Graph"]),
        .executable(name: "FuzzTestExample", targets: ["FuzzTestExample"])
    ],
    dependencies: [
        .package(url: "keybase://private/loiclec/swiftpm-fuzz", .revision("e20fad2beae3dd1eb003aa6a4813cec2006078b4"))
    ],
    targets: [
        .target(name: "FuzzTestExample", dependencies: [
            "FuzzCheck",
            "FuzzCheckTool", 
            "GraphFuzzerInputGenerator", 
            "Graph"
        ]),
        .target(name: "GraphFuzzerInputGenerator", dependencies: ["FuzzCheck", "Graph"]),
        .target(name: "Graph", dependencies: [])
    ],
    fuzzedTargets: [
        "FuzzTestExample",
        "Graph"
    ]
)
