//  Created by Luke Zhao on 10/17/21.

extension CGSize {
    /// A size with infinite width and height.
    static public let infinity: CGSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)

    /// A size with negative infinite width and height.
    static public let negativeInfinity: CGSize = CGSize(width: -CGFloat.infinity, height: -CGFloat.infinity)

    /// Represents the maximum size constraint.
    static public let constraintMaxSize: CGSize = .infinity

    /// Represents the minimum size constraint.
    static public let constraintMinSize: CGSize = .negativeInfinity
}

extension CGPoint {
    @inlinable func distance(_ point: CGPoint) -> CGFloat {
        hypot(point.x - x, point.y - y)
    }

    @inlinable static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    @inlinable static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    @inlinable static func += (left: inout CGPoint, right: CGPoint) {
        left.x += right.x
        left.y += right.y
    }
}

extension CGSize {
    @inlinable static func * (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width: left.width * right, height: left.height * right)
    }

    @inlinable func inset(by insets: UIEdgeInsets) -> CGSize {
        CGSize(width: width - insets.left - insets.right, height: height - insets.top - insets.bottom)
    }
}

extension CGRect {
    @inlinable var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    @inlinable var bounds: CGRect {
        CGRect(origin: .zero, size: size)
    }

    @inlinable static func + (left: CGRect, right: CGPoint) -> CGRect {
        CGRect(origin: left.origin + right, size: left.size)
    }

    @inlinable static func - (left: CGRect, right: CGPoint) -> CGRect {
        CGRect(origin: left.origin - right, size: left.size)
    }
}

#if os(macOS)
extension CGRect {
    @inlinable func inset(by insets: UIEdgeInsets) -> CGRect {
        CGRect(
            x: origin.x + insets.left,
            y: origin.y + insets.top,
            width: size.width - insets.left - insets.right,
            height: size.height - insets.top - insets.bottom
        )
    }
}
#endif

extension Comparable {
    @inlinable func clamp(_ minValue: Self, _ maxValue: Self) -> Self {
        self < minValue ? minValue : (self > maxValue ? maxValue : self)
    }
}

extension UIEdgeInsets {
    @inlinable static prefix func - (inset: UIEdgeInsets) -> UIEdgeInsets {
        UIEdgeInsets(top: -inset.top, left: -inset.left, bottom: -inset.bottom, right: -inset.right)
    }
}

extension Collection {
    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
            if predicate(self[mid]) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return low
    }
}
