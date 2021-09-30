//
//  Graph.swift
//
//  Created by Кузин Павел on 17.08.2021.
//

import Foundation

protocol Graphable {
    func createVertex(id: Int, x: Double, y: Double, isMCD: Bool, isOutside: Bool, isMCC: Bool)
    func add(id: Int, _ type: EdgeType, from source: Vertex, to destination: Vertex, weight: Double, isTransition: Bool)
}

class Graph : Graphable {
    
    func remove(edge: Edge) {
        guard let _ = adjacencyDict[edge.source] else { return }
        adjacencyDict[edge.source]?.removeAll(where: { $0 == edge })
    }
    
    func restore(edges: [Edge]) {
        for edge in edges {
            guard let _ = adjacencyDict[edge.source] else { continue }
            adjacencyDict[edge.source]?.append(edge)
        }
    }
    
    public func removeMCD() {
        for item in adjacencyDict.keys {
            if item.isMCD {
                adjacencyDict[item] = nil
            }
        }
    }
    
    public func removeMCC() {
        for item in adjacencyDict.keys {
            if item.isMCC {
                adjacencyDict[item] = nil
            }
        }
    }
    
    func constructPath(from vertecies: [Vertex]) -> [Edge] {
        var edges = [Edge]()
        for index in stride(from: 0, to: vertecies.count - 1, by: 1) {
            if let edge = findEdgeFor(v1: vertecies[index], v2: vertecies[index+1]) {
                edges.append(edge)
            }
        }
        return edges
    }
    
    public func vertex(by id: Int) -> Vertex? {
        return self.adjacencyDict.filter { $0.key.id == id }.keys.first
    }
    
    fileprivate func addDirectedEdge(id: Int, from source: Vertex, to destination: Vertex, weight: Double, isTransition: Bool) {
        let edge = Edge(id: id, source: source, destination: destination, weight: weight, isTransition: isTransition)
        adjacencyDict[source]!.append(edge)
    }
    
    fileprivate func addUndirectedEdge(id: Int, vertices: (Vertex, Vertex), weight: Double, isTransition: Bool) {
        let (source, destination) = vertices
        addDirectedEdge(id: id, from: source, to: destination, weight: weight, isTransition: isTransition)
        addDirectedEdge(id: id, from: destination, to: source, weight: weight, isTransition: isTransition)
    }
    
    public func createVertex(id: Int, x: Double, y: Double, isMCD: Bool, isOutside: Bool, isMCC: Bool) {
        let vertex = Vertex(id: id, x: x, y: y, isMCD: isMCD, isOutside: isOutside, isMCC: isMCC)
        
        if adjacencyDict[vertex] == nil {
            adjacencyDict[vertex] = []
        }
    }
    
    func add(id: Int, _ type: EdgeType, from source: Vertex, to destination: Vertex, weight: Double, isTransition: Bool) {
        switch type {
        case .directed:
            addDirectedEdge(id: id, from: source, to: destination, weight: weight, isTransition: isTransition)
        case .undirected:
            addUndirectedEdge(id: id, vertices: (source, destination), weight: weight, isTransition: isTransition)
        }
    }
    
    var adjacencyDict : [Vertex: [Edge]] = [:]
    
    func findEdgeFor(v1: Vertex, v2: Vertex) -> Edge? {
        if let edgesV1 = adjacencyDict[v1] {
            let result = edgesV1.filter { $0.destination == v2 }
            if !result.isEmpty {
                return result[0]
            }
        }
        return nil
    }
    
    func findEdge(by id: Int, isTransition: Bool) -> Edge? {
        let result = adjacencyDict.values.filter { (element) -> Bool in
            return element.contains(where: { $0.id == id && $0.isTransition == isTransition })
        }
        if !result.isEmpty {
            if let first = result.first, let edge = first.filter({ $0.id == id }).first {
                return edge
            }
        }
        return nil
    }
    
    func findEdgeFor(v1: Vertex, v2: Vertex, isTransition: Bool) -> Edge? {
        if let edgesV1 = adjacencyDict[v1] {
            let result = edgesV1.filter { $0.destination == v2 || $0.isTransition == isTransition}
            if !result.isEmpty {
                return result[0]
            }
        }
        return nil
    }
}

public protocol AStarPathable : AnyObject {
    associatedtype KeyType: Hashable
    func neighbors(of nodeKey: KeyType) -> [KeyType]
    func cost(from source: KeyType, to dest: KeyType, isAvoidingMCD: Bool, isAvoidingMCC: Bool) -> Double?
    func heuristic(from source: KeyType, to dest: KeyType) -> Double
}

extension Graph : AStarPathable {
    
    public typealias KeyType = Vertex
    
    public func neighbors(of nodeKey: Vertex) -> [Vertex] {
        if adjacencyDict[nodeKey] != nil {
            return adjacencyDict[nodeKey]!.map { $0.destination }
        } else {
            return []
        }
    }
    
    public func cost(from source: Vertex, to dest: Vertex, isAvoidingMCD: Bool, isAvoidingMCC: Bool) -> Double? {
        if let edgesFromSource = adjacencyDict[source] {
            let result = edgesFromSource.filter { $0.destination == dest }
            if !result.isEmpty {
                guard
                    let first = result.first
                else { return nil }
                if first.source.isMCD || first.destination.isMCD {
                    if isAvoidingMCD {
                        return first.weight + 250
                    }
                }
                return first.weight
            }
        }
        return nil
    }
    
    public func heuristic(from s: Vertex, to t: Vertex) -> Double {
        let dx = abs(s.x - t.x)
        let dy = abs(s.y - t.y)
        return 1 * (dx + dy) + (1 - 2 * 1) * min(dx, dy)
    }
}

extension Graph : NSCopying {
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = Graph()
        copy.adjacencyDict = self.adjacencyDict
        return copy
    }
}
