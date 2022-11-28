import Foundation

public func clamp<T>(_ value: T, _ minValue: T, _ maxValue: T) -> T where T : Comparable {
    return min(max(value, minValue), maxValue)
}
