//  Created by Luke Zhao on 10/17/21.


import UIKit

extension CGSize {
    static public let constraintMaxSize: CGSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)

    static public let constraintMinSize: CGSize = CGSize(width: -CGFloat.infinity, height: -CGFloat.infinity)
}

extension CGPoint {
    @inlinable public func distance(_ point: CGPoint) -> CGFloat {
        hypot(point.x - x, point.y - y)
    }

    @inlinable public static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    @inlinable public static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    @inlinable public static func += (left: inout CGPoint, right: CGPoint) {
        left.x += right.x
        left.y += right.y
    }
}

extension CGSize {
    @inlinable public static func * (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width: left.width * right, height: left.height * right)
    }

    public func inset(by insets: UIEdgeInsets) -> CGSize {
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

    @inlinable public static func + (left: CGRect, right: CGPoint) -> CGRect {
        CGRect(origin: left.origin + right, size: left.size)
    }

    @inlinable public static func - (left: CGRect, right: CGPoint) -> CGRect {
        CGRect(origin: left.origin - right, size: left.size)
    }
}

extension Comparable {
    public func clamp(_ minValue: Self, _ maxValue: Self) -> Self {
        self < minValue ? minValue : (self > maxValue ? maxValue : self)
    }
}

extension UIEdgeInsets {
    static public prefix func - (inset: UIEdgeInsets) -> UIEdgeInsets {
        UIEdgeInsets(top: -inset.top, left: -inset.left, bottom: -inset.bottom, right: -inset.right)
    }
}

extension Collection {
    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    public func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index {
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
