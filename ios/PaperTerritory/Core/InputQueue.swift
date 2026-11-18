import Foundation

/// Fixed-capacity (max 2) turn command buffer preventing 180-degree instant reversals
/// and preserving rapid corner inputs until the entity reaches the next cell center.
struct InputQueue: Sendable {
    private var first: Direction?
    private var second: Direction?

    var count: Int {
        if first == nil { return 0 }
        return second == nil ? 1 : 2
    }

    var isEmpty: Bool {
        first == nil
    }

    /// Enqueues a requested cardinal turn if it is valid relative to the latest pending or active direction.
    /// Returns `true` if queued, `false` if rejected (same direction, 180-degree opposite, or buffer full).
    @discardableResult
    mutating func enqueue(_ direction: Direction, currentDirection: Direction) -> Bool {
        let reference = second ?? first ?? currentDirection
        if direction == reference || direction.isOpposite(to: reference) {
            return false
        }

        if first == nil {
            first = direction
            return true
        }
        if second == nil {
            second = direction
            return true
        }
        return false
    }

    /// Pops and validates the next queued turn against the current movement direction.
    mutating func popNextValid(currentDirection: Direction) -> Direction? {
        while let candidate = first {
            first = second
            second = nil
            if candidate != currentDirection, !candidate.isOpposite(to: currentDirection) {
                return candidate
            }
        }
        return nil
    }

    mutating func clear() {
        first = nil
        second = nil
    }
}
