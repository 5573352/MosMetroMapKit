open class Gradient: Fill {

    public let userSpace: Bool
    public let stops: [MStop]

    public init(userSpace: Bool = false, stops: [MStop] = []) {
        self.userSpace = userSpace
        self.stops = stops
    }

    override func equals<T>(other: T) -> Bool where T: Fill {
        guard let other = other as? Gradient, userSpace == other.userSpace else {
            return false
        }

        if stops.isEmpty && other.stops.isEmpty {
            return true
        }

        return stops.elementsEqual(other.stops)
    }
}
