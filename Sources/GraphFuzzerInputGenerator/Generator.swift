
import FuzzCheck
import Graph

public struct GraphFuzzerInputGenerator <G: FuzzerInputGenerator> : FuzzerInputMutatorGroup, FuzzerInputGenerator
    where
    G.Input: Codable,
    G.Input: RandomInitializable
{
    public func newInput(maxComplexity: Double, _ rand: inout FuzzerPRNG) -> Graph<G.Input> {
        let actualComplexity = Double.random(in: 0 ..< maxComplexity, using: &rand)
        var g = Graph<G.Input>()
        while GraphFuzzerInputGenerator.complexity(of: g) < actualComplexity {
            _ = Bool.random(using: &rand) ? addVertex(&g, &rand) : addEdge(&g, &rand)
        }
        while GraphFuzzerInputGenerator.complexity(of: g) > actualComplexity {
            _ = Bool.random(using: &rand) ? removeVertex(&g, &rand) : removeEdge(&g, &rand)
        }
        return g
    }
    
    public typealias Input = Graph<G.Input>
    public let baseInput: Graph<G.Input> = Graph()
 
    var vertexGenerator: G
    
    public init(vertexGenerator: G) {
        self.vertexGenerator = vertexGenerator
    }
    
    public enum Mutator {
        case addVertices
        case addEdges
        case splitEdge
        case addFriend
        case moveEdge
        case addEdge
        case removeEdge
        case addVertex
        case removeVertex
        case modifyVertexData
    }
    
    public func mutate(_ input: inout Input, with mutator: Mutator, spareComplexity: Double, _ rand: inout FuzzerPRNG) -> Bool {
        switch mutator {
        case .addVertices:
            return addVertices(&input, &rand)
        case .addEdges:
            return addEdges(&input, &rand)
        case .splitEdge:
            return splitEdge(&input, &rand)
        case .addFriend:
            return addFriend(&input, &rand)
        case .moveEdge:
            return moveEdge(&input, &rand)
        case .addEdge:
            return addEdge(&input, &rand)
        case .removeEdge:
            return removeEdge(&input, &rand)
        case .addVertex:
            return addVertex(&input, &rand)
        case .removeVertex:
            return removeVertex(&input, &rand)
        case .modifyVertexData:
            return modifyVertexData(&input, &rand)
        }
    }
    
    func splitEdge(_ x: inout Input, _ r: inout FuzzerPRNG) -> Bool {
        
        guard let fromIndex = x.vertices.indices.randomElement(using: &r) else {
            return false
        }
        let fromData = x.vertices[fromIndex]
        
        guard let oldDestEdgeIndex = fromData.edges.indices.randomElement(using: &r) else {
            return false
        }
        
        let oldDest = fromData.edges[oldDestEdgeIndex]
        x.removeEdge(from: fromIndex, to: oldDestEdgeIndex)
        let newVertex = x.addVertex(G.Input.random(using: &r))
        x.addEdge(from: fromIndex, to: newVertex)
        x.addEdge(from: newVertex, to: oldDest)
        return true
    }
    
    func addFriend(_ x: inout Input, _ r: inout FuzzerPRNG) -> Bool {
        guard let from = x.vertices.indices.randomElement(using: &r) else {
            return false
        }
        let newVertex = x.addVertex(G.Input.random(using: &r))
        x.addEdge(from: from, to: newVertex)
        return true
    }
    
    func moveEdge(_ x: inout Input, _ r: inout FuzzerPRNG) -> Bool {
        guard let fromIndex = x.vertices.indices.randomElement(using: &r) else {
            return false
        }
        let fromData = x.vertices[fromIndex]
        guard let oldDest = fromData.edges.indices.randomElement(using: &r) else {
            return false
        }
        x.removeEdge(from: fromIndex, to: oldDest)
        let newDest = x.vertices.indices.randomElement(using: &r)!
        x.addEdge(from: fromIndex, to: newDest)
        return true
    }
    
    func addEdge(_ x: inout Input, _ r: inout FuzzerPRNG) -> Bool {
        guard !x.vertices.isEmpty else { return false }
        let vi = x.vertices.indices.randomElement(using: &r)!
        let vj = x.vertices.indices.randomElement(using: &r)!
        x.addEdge(from: vi, to: vj)
        return true
    }
    func addEdges(_ x: inout Input, _ r: inout FuzzerPRNG) -> Bool {
        guard let vi = x.vertices.indices.randomElement(using: &r) else {
            return false
        }
        
        let count = (1 ... x.vertices.count).randomElement(using: &r)!
        for _ in 0 ..< count {
            let vj = x.vertices.indices.randomElement(using: &r)!
            x.addEdge(from: vi, to: vj)
        }
        return true
    }
    
    func removeEdge(_ x: inout Input, _ r: inout FuzzerPRNG) -> Bool {
        guard let vi = x.vertices.indices.randomElement(using: &r) else {
            return false
        }
        let v = x.vertices[vi]
        guard let ei = v.edges.indices.randomElement(using: &r) else {
            return false
        }
        x.removeEdge(from: vi, to: ei)
        return true
    }
    
    func addVertex(_ x: inout Input, _ r: inout FuzzerPRNG) -> Bool {
        _ = x.addVertex(G.Input.random(using: &r))
        return true
    }
    func addVertices(_ x: inout Input, _ r: inout FuzzerPRNG) -> Bool {
        let count = (1 ... max(20, x.vertices.count)).randomElement(using: &r)!
        for _ in 0 ..< count {
            _ = x.addVertex(G.Input.random(using: &r))
        }
        return true
    }
    
    func removeVertex(_ x: inout Input, _ r: inout FuzzerPRNG) -> Bool {
        guard !x.vertices.isEmpty else { return false }
        let i = x.vertices.indices.randomElement(using: &r)!
        x.removeVertex(i)
        return true
    }
    
    func modifyVertexData(_ x: inout Input, _ r: inout FuzzerPRNG) -> Bool {
        guard !x.vertices.isEmpty else { return false }
        
        let i = x.vertices.indices.randomElement(using: &r)!
        return vertexGenerator.mutate(&x.vertices[i].data, 0, &r)
    }
    
    public let weightedMutators: [(Mutator, UInt)] = [
        (.addVertices, 5),
        (.addEdges, 10),
        (.addFriend, 30),
        (.moveEdge, 47),
        (.addEdge, 77),
        (.removeEdge, 87),
        (.addVertex, 97),
        (.removeVertex, 107),
        (.modifyVertexData, 157),
    ]
    
    public static func hash(_ input: Graph<G.Input>, into hasher: inout Hasher) {
        for v in input.vertices {
            G.hash(v.data, into: &hasher)
            v.edges.hash(into: &hasher)
        }
    }
    
    public static func complexity(of input: Graph<G.Input>) -> Double {
        return Double(input.totalSize)
//        var cplx = 1.0
//        for v in input {
//            cplx += P.complexity(of: v.data)
//            cplx += Double(v.edges.count)
//        }
//        return cplx
    }
}
