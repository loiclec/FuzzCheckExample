//
//  Graph.swift
//  BinaryCoder
//
//  Created by Loïc Lecrenier on 08/03/2018.
//

/// Append-only simple graph

public struct Graph <V> {
    
    public struct Vertex {
        public var data: V
        public var edges: [Int]
    }
    
    public var vertices: [Vertex]
    
    public var totalSize: Int
}

extension Graph {
    public init() {
        self.vertices = []
        self.totalSize = 0
    }
}

extension Graph {
    public mutating func addVertex(_ data: V) -> Int {
        let index = vertices.endIndex
        self.vertices.append(Vertex(data: data, edges: []))
        self.totalSize += 1
        return index
    }
    public mutating func addEdge(from: Int, to: Int) {
        totalSize += 1
        self.vertices[from].edges.append(to)
    }
    public mutating func removeVertex(_ idx: Int) {
        vertices.remove(at: idx)
        totalSize -= 1
        for i in vertices.indices {
            let before = vertices[i].edges.count
            vertices[i].edges.removeAll(where: { $0 == idx })
            let after = vertices[i].edges.count
            totalSize -= before - after
            for j in vertices[i].edges.indices {
                if vertices[i].edges[j] > idx {
                    vertices[i].edges[j] -= 1
                }
            }
        }
    }
    public mutating func removeEdge(from: Int, to: Int) {
        vertices[from].edges.remove(at: to)
        totalSize -= 1
    }
}

extension Graph {
    public func dotDescription() -> String {
        let content = zip(vertices.indices, vertices).map { (i, v) in
            "\n\t\"\(i). \(v.data)\";" + v.edges.map { edge in
                "\n\t\"\(i). \(v.data)\" -> \"\(edge). \(vertices[edge].data)\";"
                }.joined()
            }.joined()
        return """
        digraph G {
        \(content)
        }
        """
    }
}

struct Pair <A, B> : Codable where A: Codable, B: Codable {
    let a : A
    let b : B
    
    init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.a = try container.decode(A.self)
        self.b = try container.decode(B.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(a)
        try container.encode(b)
    }
}

extension Graph: Codable where V: Codable {
    public init(from decoder: Decoder) throws {
        self.init()
        let array = try Array<Pair<V, [Int]>>(from: decoder)
        for p in array {
            let vi = self.addVertex(p.a)
            for e in p.b {
                self.addEdge(from: vi, to: e)
            }
        }
    }
    public func encode(to encoder: Encoder) throws {
        try self.vertices.map { Pair($0.data, $0.edges) }.encode(to: encoder)
    }
}
