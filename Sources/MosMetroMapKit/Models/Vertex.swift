

public class Vertex {
    public let id: Int
    public let x: Double
    public let y: Double
    public let isMCD: Bool
    public let isMCC: Bool
    public let isOutside: Bool
    
    init(id: Int, x: Double, y: Double, isMCD: Bool, isOutside: Bool, isMCC: Bool) {
        self.id = id
        self.x = x
        self.y = y
        self.isMCD = isMCD
        self.isMCC = isMCC
        self.isOutside = isOutside
    }
}

extension Vertex: Hashable {
	public var hashValue: Int {
		return "\(id)".hashValue
	}
	
	static public func ==(lhs: Vertex, rhs: Vertex) -> Bool {
		return lhs.id == rhs.id
	}
}
