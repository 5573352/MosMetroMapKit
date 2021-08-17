//
//  PathFinder.swift
//  PackageTester
//
//  Created by Кузин Павел on 17.08.2021.
//

import Foundation

public struct PriorityQueue<Element> where Element: Hashable {
    
    private enum PriorityQueueType {
        
        case max
        case min
        
        fileprivate func shouldPromote(_ d1: Double, against d2: Double) -> Bool {
            if d1 == d2 {
                return false
            }
            switch self {
            case .max:
                return d1 > d2
            case .min:
                return d1 < d2
            }
        }
    }
    
    private struct Node {
        
        let value: Element
        let priority: Double
        
    }
    
    // MARK: - Factory Properties
    
    public static var maxQueue: PriorityQueue<Element> {
        return PriorityQueue(queueType: .max)
    }
    
    public static var minQueue: PriorityQueue<Element> {
        return PriorityQueue(queueType: .min)
    }
    
    // MARK: - Properties
    
    private let queueType: PriorityQueueType
    
    private var heap: [Node] = []
    
    private var mirror: [Element: Int] = [:]
    
    public var count: Int {
        return heap.count
    }
    
    // MARK: - Initialization
    
    private init(queueType: PriorityQueueType) {
        self.queueType = queueType
    }
    
    // MARK: - Public Interface
    
    /// Enqueue's an `Element` into the `PriorityQueue`. If a value is already in
    /// the `PriorityQueue`, it will be replaced with the new priority. O(log n)
    /// complexity.
    ///
    /// - Parameters:
    ///   - element: The value enqueued into the `PriorityQueue`.
    ///   - priority: The priority of the `Element`.
    public mutating func enqueue(
        _ element: Element,
        withPriority priority: Double
    ) {
        if let existingIdx = mirror[element] {
            // Reprioritize the existing Node.
            heap[existingIdx] = Node(value: element, priority: priority)
            bubbleDown(at: existingIdx)
            bubbleUp(at: existingIdx)
            return
        }
        let newIdx = count
        heap.append(Node(value: element, priority: priority))
        mirror[element] = newIdx
        bubbleUp(at: newIdx)
    }
    
    /// Removes and returns the value at the front of the `PriorityQueue`. This is
    /// the value with the highest priority in a max-queue or the lowest priority
    /// in a min-queue. O(log n) complexity due to restoring the heap invariant
    /// after a dequeue.
    ///
    /// - Returns: The value at the front of the `PriorityQueue`.
    public mutating func dequeue() -> Element? {
        // Get the element with the highest priority.
        guard let retval = heap.first else { return nil }
        // Put the last element in the first spot, removing the element that
        // is about to be returned.
        heap.swapAt(0, count - 1)
        mirror.removeValue(forKey: retval.value)
        mirror[heap[0].value] = 0
        heap.removeLast()
        // Restore Heap invariant.
        bubbleDown(at: 0)
        
        return retval.value
    }
    
    /// Returns `true` if the element is found in the `PriorityQueue`.
    /// O(1) complexity.
    public func contains(_ element: Element) -> Bool {
        return mirror[element] != nil
    }
    
    /// Reprioritizes (re-orders) the `element` if the priority is higher (in a
    /// max-queue) or lower (in a min-queue). If the element is not found or the
    /// priority isn't better, this no-ops. O(log n) complexity.
    public mutating func reprioritizeIfBetter(
        _ element: Element,
        withPriority priority: Double
    ) {
        guard let idx = mirror[element] else { return }
        if queueType.shouldPromote(priority, against: heap[idx].priority) {
            enqueue(element, withPriority: priority)
        }
    }
    
    // MARK: - Private
    
    private static func parentIdx(of idx: Int) -> Int {
        return (idx - 1) / 2
    }
    
    private static func leftChildIdx(of idx: Int) -> Int {
        return idx * 2 + 1
    }
    
    private static func rightChildIdx(of idx: Int) -> Int {
        return idx * 2 + 2
    }
    
    private func shouldPromoteChild(idx: Int) -> Bool {
        let childPriority = heap[idx].priority
        let parentPriority = heap[PriorityQueue.parentIdx(of: idx)].priority
        return queueType.shouldPromote(childPriority, against: parentPriority)
    }
    
    private mutating func bubbleDown(at idx: Int) {
        var idx = idx
        while idx < heap.count {
            let leftChildIdx = PriorityQueue.leftChildIdx(of: idx)
            if leftChildIdx >= count {
                // No children, done bubbling.
                break
            }
            let rightChildIdx = PriorityQueue.rightChildIdx(of: idx)
            let targetChildIdx: Int
            if rightChildIdx >= count {
                // No right child, use the left child.
                targetChildIdx = leftChildIdx
            } else {
                // Figure out which child is better and swap with that child.
                targetChildIdx = queueType.shouldPromote(
                    heap[leftChildIdx].priority,
                    against: heap[rightChildIdx].priority
                    ) ? leftChildIdx : rightChildIdx
            }
            
            guard queueType.shouldPromote(
                heap[targetChildIdx].priority,
                against: heap[idx].priority
                ) else {
                    // Parent is in the correct spot, don't bubble anymore.
                    break
            }
            
            heap.swapAt(idx, targetChildIdx)
            mirror[heap[idx].value] = idx
            mirror[heap[targetChildIdx].value] = targetChildIdx
            
            idx = targetChildIdx
        }
    }
    
    private mutating func bubbleUp(at idx: Int) {
        var idx = idx
        while idx != 0 && shouldPromoteChild(idx: idx) {
            let parentIdx = PriorityQueue.parentIdx(of: idx)
            heap.swapAt(parentIdx, idx)
            mirror[heap[idx].value] = idx
            mirror[heap[parentIdx].value] = parentIdx
            idx = parentIdx
        }
    }
    
}


public final class AStarPathNode<KeyType> where KeyType: Hashable {
    
    // Identifies the node.
    public let nodeKey: KeyType
    
    // Cost of going from start to this node.
    public var baseCost: Double = 0
    
    // Estimated cost of going from this node to the destination.
    public var estimateRemaining: Double = 0
    
    /// Previous node in the path back to the starting node, if nil, this is the
    /// starting node.
    public var previousNode: AStarPathNode<KeyType>?
    
    public init(nodeKey: KeyType) {
        self.nodeKey = nodeKey
    }
    
}

extension AStarPathNode: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(nodeKey)
    }
    
    public static func ==(lhs: AStarPathNode, rhs: AStarPathNode) -> Bool {
        return lhs.nodeKey == rhs.nodeKey
    }
    
}

public final class AStarPathfinder<KeyType, GraphType> where
    GraphType: AStarPathable,
    GraphType.KeyType == KeyType
{
    
    public typealias NodeType = AStarPathNode<KeyType>
    
    weak var pathable: GraphType?
    
    private var openSet: PriorityQueue<NodeType> = .minQueue
    
    private var closedSet: Set<NodeType> = []
    
    public init(pathable: GraphType) {
        self.pathable = pathable
    }
    
    var isAvoidingMCC = false
    var isAvoidingMCD = false
    
    /// Finds the shortest path between `source` and `dest`, if possible.
    ///
    /// - Parameters:
    ///   - source: The key for the starting location.
    ///   - dest: The key for the ending location to path to.
    /// - Returns: A list of `NodeType` representing the shortest path or an empty
    ///   list if no path exists.
    public func path(from source: KeyType, to dest: KeyType) -> [NodeType] {
        closedSet = []
        openSet = .minQueue
        guard let pathable = pathable else { return [] }
        if let sourceVertex = source as? Vertex, let destVertex = dest as? Vertex {
            if sourceVertex.isMCD || destVertex.isMCD {
                isAvoidingMCD = false
            } else {
                isAvoidingMCD = true
            }
            
            if sourceVertex.isMCC || destVertex.isMCC {
                isAvoidingMCC = false
            } else {
                isAvoidingMCC = true
            }
        }
        
        let sourceNode = AStarPathNode(nodeKey: source)
        let destNode = AStarPathNode(nodeKey: dest)
        openSet.enqueue(sourceNode, withPriority: 0)
        while let bestNode = openSet.dequeue() {
            closedSet.insert(bestNode)
            if bestNode == destNode {
                // Found best! OMG!
                return chain(bestNode).reversed()
                
                
            } else {
                for neighborKey in pathable.neighbors(of: bestNode.nodeKey) {
                    let neighbor = AStarPathNode(nodeKey: neighborKey)
                    process(
                        node: neighbor,
                        potentialParent: bestNode,
                        dest: destNode,
                        pathable: pathable
                    )
                }
            }
        }
        return []
    }
    
    private func process(node: NodeType, potentialParent: NodeType, dest: NodeType, pathable: GraphType) {
        guard !closedSet.contains(node) else { return }
        // Cost from the parent to the test node.
        guard let cost = pathable.cost(from: potentialParent.nodeKey, to: node.nodeKey, isAvoidingMCD: isAvoidingMCD, isAvoidingMCC: isAvoidingMCC) else { return }
        let newCost = cost + potentialParent.baseCost
        node.baseCost = newCost
        node.estimateRemaining = pathable.heuristic(
            from: node.nodeKey,
            to: dest.nodeKey)
        node.previousNode = potentialParent
        let estimatedTotalCost = node.baseCost + node.estimateRemaining
        if !openSet.contains(node) {
            openSet.enqueue(node, withPriority: estimatedTotalCost)
        } else {
            openSet.reprioritizeIfBetter(node, withPriority: estimatedTotalCost)
        }
    }
    
    private func chain(_ node: NodeType) -> [NodeType] {
        var retval: [NodeType] = []
        var node = node
        repeat {
            retval.append(node)
            guard let previous = node.previousNode else { break }
            node = previous
        } while true
        return retval
    }
    
}

