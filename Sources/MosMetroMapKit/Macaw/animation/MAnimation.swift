public enum AnimationState {
    case initial
    case running
    case paused
}

public class MAnimation {

    internal init() {
    }

    public func play() {
    }

    public func stop() {
    }

    public func pause() {

    }

    public func state() -> AnimationState {
        return .initial
    }

    public func easing(_ easing: Easing) -> MAnimation {
        return self
    }

    public func delay(_ delay: Double) -> MAnimation {
        return self
    }

    public func cycle(_ count: Double) -> MAnimation {
        return self
    }

    public func cycle() -> MAnimation {
        return self
    }

    public func reverse() -> MAnimation {
        return self
    }

    public func autoreversed() -> MAnimation {
        return self
    }

    @discardableResult public func onComplete(_: @escaping (() -> Void)) -> MAnimation {
        return self
    }
}
