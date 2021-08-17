import Foundation


public enum EdgeType {
	case directed, undirected
}

public class Edge {
   
    
    public var id: Int
    public var source: Vertex
    public var destination: Vertex
	public var weight: Double
    public var isTransition: Bool

    
    init(id: Int, source: Vertex, destination: Vertex, weight: Double, isTransition: Bool) {
        self.id = id
        self.source = source
        self.destination = destination
        self.weight = weight
        self.isTransition = isTransition
    }
    
}

extension Edge: Hashable {
        
   public var hashValue: Int {
        return "\(source)\(destination)\(weight)".hashValue
    }
	
	static public func ==(lhs: Edge, rhs: Edge) -> Bool {
		return lhs.source == rhs.source &&
			lhs.destination == rhs.destination &&
			lhs.weight == rhs.weight 
	}
}

