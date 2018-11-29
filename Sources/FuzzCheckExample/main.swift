
import FuzzCheck
import GraphFuzzerInputGenerator
import Graph

func test(_ g: Graph<UInt8>) -> Bool {
     if
        g.vertices.count == 8,
        g.vertices[0].data == 100,
        g.vertices[1].data == 89,
        g.vertices[2].data == 10,
        g.vertices[3].data == 210,
        g.vertices[4].data == 1,
        g.vertices[5].data == 210,
        g.vertices[6].data == 9,
        g.vertices[7].data == 17,
        g.vertices[0].edges.count == 2,
        g.vertices[0].edges[0] == 1,
        g.vertices[0].edges[1] == 2,
        g.vertices[1].edges.count == 2,
        g.vertices[1].edges[0] == 3,
        g.vertices[1].edges[1] == 4,
        g.vertices[2].edges.count == 2,
        g.vertices[2].edges[0] == 5,
        g.vertices[2].edges[1] == 6,
        g.vertices[3].edges.count == 1,
        g.vertices[3].edges[0] == 7,
        g.vertices[4].edges.count == 0,
        g.vertices[5].edges.count == 0,
        g.vertices[6].edges.count == 0,
        g.vertices[7].edges.count == 0
    {
        return false
    }
    return true
}

let generator = 
    GraphFuzzerInputGenerator<IntegerFuzzerGenerator<UInt8>>(
        vertexGenerator: .init()
    )

try CommandLineFuzzer.launch(
    test: test, 
    generator: generator
)















