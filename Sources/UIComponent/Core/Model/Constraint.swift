//  Created by Luke Zhao on 8/22/20.

import BaseToolbox
import UIKit

public struct EnvironmentKeys {
    internal static let shared = EnvironmentKeys()
}

extension EnvironmentKeys {
    var viewBoundingSize: EnvironmentKey<CGSize> { .init(defaultValue: .zero) }
    public var textColor: EnvironmentKey<UIColor?> { .init(defaultValue: nil) }
    public var tintColor: EnvironmentKey<UIColor?> { .init(defaultValue: nil) }
    public var foregroundColor: EnvironmentKey<UIColor?> { .init(defaultValue: nil) }
}

public struct EnvironmentKey<Value> {
    var defaultValue: Value
}

public protocol Constraint {
    var minSize: CGSize { get }
    var maxSize: CGSize { get }
    subscript<T>(key: KeyPath<EnvironmentKeys, EnvironmentKey<T>>) -> T { get }
}

extension Constraint {
    public var isTight: Bool { minSize == maxSize }
    
    public func inset(by insets: UIEdgeInsets) -> Constraint {
        InsetConstraint(child: self, insets: insets)
    }
    
    public func with(tightSize: CGSize) -> Constraint {
        SizeOverrideConstraint(child: self, minSize: tightSize, maxSize: tightSize)
    }
    
    public func with(maxSize: CGSize) -> Constraint {
        SizeOverrideConstraint(child: self, maxSize: maxSize)
    }
    
    public func with(minSize: CGSize) -> Constraint {
        SizeOverrideConstraint(child: self, minSize: minSize)
    }
    
    public func with(minSize: CGSize, maxSize: CGSize) -> Constraint {
        SizeOverrideConstraint(child: self, minSize: minSize, maxSize: maxSize)
    }
    
    public func with<T>(_ key: KeyPath<EnvironmentKeys, EnvironmentKey<T>>, _ value: T) -> Constraint {
        EnvironmentConstraint(child: self, key: key, value: value)
    }
    
    public func withNoMinSize() -> Constraint {
        SizeOverrideConstraint(child: self, minSize: -.infinity)
    }
    
    public func withNoMaxSize() -> Constraint {
        SizeOverrideConstraint(child: self, maxSize: .infinity)
    }
    
    public subscript<T>(key: KeyPath<EnvironmentKeys, EnvironmentKey<T>>) -> T {
        EnvironmentKeys.shared[keyPath: key].defaultValue
    }
}

internal struct BaseConstraint: Constraint {
    var viewBoundingSize: CGSize
    var minSize: CGSize {
        -.infinity
    }
    var maxSize: CGSize {
        viewBoundingSize
    }
    subscript<T>(key: KeyPath<EnvironmentKeys, EnvironmentKey<T>>) -> T {
        if key == \.viewBoundingSize {
            return viewBoundingSize as! T
        } else {
            return EnvironmentKeys.shared[keyPath: key].defaultValue
        }
    }
}

public protocol WrapperConstraint: Constraint {
    var child: Constraint { get }
}

extension WrapperConstraint {
    public var minSize: CGSize {
        child.minSize
    }
    public var maxSize: CGSize {
        child.maxSize
    }
    public subscript<T>(key: KeyPath<EnvironmentKeys, EnvironmentKey<T>>) -> T {
        child[key]
    }
}

extension Component {
    public func environment<T>(key: KeyPath<EnvironmentKeys, EnvironmentKey<T>>, value: T) -> Component {
        constraint {
            $0.with(key, value)
        }
    }
    public func environmentTextColor(_ color: UIColor) -> Component {
        environment(key: \.textColor, value: color)
    }
    public func environmentTintColor(_ color: UIColor) -> Component {
        environment(key: \.tintColor, value: color)
    }
    public func environmentForegroundColor(_ color: UIColor) -> Component {
        environment(key: \.foregroundColor, value: color)
    }
}

public struct EnvironmentConstraint<T>: WrapperConstraint {
    public var child: Constraint
    public var key: KeyPath<EnvironmentKeys, EnvironmentKey<T>>
    public var value: T
    public subscript<T>(key: KeyPath<EnvironmentKeys, EnvironmentKey<T>>) -> T {
        if key == self.key {
            return value as! T
        } else {
            return child[key]
        }
    }
}

public struct SizeOverrideConstraint: WrapperConstraint {
    public var child: Constraint
    public var minSizeOverride: CGSize?
    public var maxSizeOverride: CGSize?
    public var minSize: CGSize {
        minSizeOverride ?? child.minSize
    }
    public var maxSize: CGSize {
        maxSizeOverride ?? child.maxSize
    }
    
    internal init(child: Constraint, minSize: CGSize? = nil, maxSize: CGSize? = nil) {
        self.minSizeOverride = minSize
        self.maxSizeOverride = maxSize
        self.child = child
    }
}

public struct InsetConstraint: WrapperConstraint {
    public var child: Constraint
    public var insets: UIEdgeInsets
    public var minSize: CGSize {
        CGSize(
            width: max(0, child.minSize.width == .infinity ? .infinity : child.minSize.width - insets.left - insets.right),
            height: max(0, child.minSize.height == .infinity ? .infinity : child.minSize.height - insets.top - insets.bottom)
        )
    }
    public var maxSize: CGSize {
        CGSize(
            width: max(0, child.maxSize.width == .infinity ? .infinity : child.maxSize.width - insets.left - insets.right),
            height: max(0, child.maxSize.height == .infinity ? .infinity : child.maxSize.height - insets.top - insets.bottom)
        )
    }
}

extension CGSize {
    public func bound(to constraint: Constraint) -> CGSize {
        CGSize(
            width: width.clamp(constraint.minSize.width, constraint.maxSize.width),
            height: height.clamp(constraint.minSize.height, constraint.maxSize.height)
        )
    }
}
