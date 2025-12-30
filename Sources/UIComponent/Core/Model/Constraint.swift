//  Created by Luke Zhao on 8/22/20.


/// A structure representing constraints for sizing an element, with minimum and maximum size limits.
public struct Constraint {
    /// The minimum size that the element should at least occupy.
    public var minSize: CGSize
    /// The maximum size that the element should not exceed.
    public var maxSize: CGSize
    /// A Boolean value indicating whether the minimum and maximum sizes are equal, implying a fixed size.
    public var isTight: Bool { minSize == maxSize }

    /// Initializes a new constraint with optional minimum and maximum size parameters.
    /// - Parameters:
    ///   - minSize: The minimum size of the element. Defaults to `.constraintMinSize`.
    ///   - maxSize: The maximum size of the element. Defaults to `.constraintMaxSize`.
    public init(minSize: CGSize = .constraintMinSize,
                maxSize: CGSize = .constraintMaxSize) {
        self.minSize = minSize
        self.maxSize = maxSize
    }
    
    /// Initializes a new constraint with a fixed size.
    /// - Parameter tightSize: The fixed size for both minimum and maximum size of the element.
    public init(tightSize: CGSize) {
        self.minSize = tightSize
        self.maxSize = tightSize
    }

    /// Returns a new constraint that is inset by the specified edge insets.
    /// - Parameter insets: The edge insets to inset the constraint by.
    /// - Returns: A new `Constraint` instance with the inset sizes.
    public func inset(by insets: UIEdgeInsets) -> Constraint {
        Constraint(
            minSize: CGSize(
                width: max(0, minSize.width == .infinity ? .infinity : minSize.width - insets.left - insets.right),
                height: max(0, minSize.height == .infinity ? .infinity : minSize.height - insets.top - insets.bottom)
            ),
            maxSize: CGSize(
                width: max(0, maxSize.width == .infinity ? .infinity : maxSize.width - insets.left - insets.right),
                height: max(0, maxSize.height == .infinity ? .infinity : maxSize.height - insets.top - insets.bottom)
            )
        )
    }
}

extension CGSize {
    /// Constrains the current size to the limits defined by the given `Constraint`.
    /// - Parameter constraint: The `Constraint` to which the current size should be bound.
    /// - Returns: A new `CGSize` instance that is within the bounds of the given `Constraint`.
    public func bound(to constraint: Constraint) -> CGSize {
        CGSize(
            width: width.clamp(constraint.minSize.width, constraint.maxSize.width),
            height: height.clamp(constraint.minSize.height, constraint.maxSize.height)
        )
    }

    /// Constrains the current size to the limits defined by the given `Constraint`, while trying to maintain the aspect ratio.
    /// - Parameter constraint: The `Constraint` to which the current size should be bound.
    /// - Returns: A new `CGSize` instance that is within the bounds of the given `Constraint`, while trying maintaining the aspect ratio.
    public func boundWithAspectRatio(to constraint: Constraint) -> CGSize {
        let clampedSize = bound(to: constraint)
        if clampedSize.width != width {
            let scale = clampedSize.width / width
            let preferredHeight = height * scale
            let clampedHeight = preferredHeight.clamp(constraint.minSize.height, constraint.maxSize.height)
            if clampedHeight != preferredHeight {
                let scale = clampedHeight / height
                let preferredWidth = width * scale
                let clampedWidth = preferredWidth.clamp(constraint.minSize.width, constraint.maxSize.width)
                return CGSize(width: clampedWidth, height: clampedHeight)
            }
            return CGSize(width: clampedSize.width, height: clampedHeight)
        } else if clampedSize.height != height {
            let scale = clampedSize.height / height
            let preferredWidth = width * scale
            let clampedWidth = preferredWidth.clamp(constraint.minSize.width, constraint.maxSize.width)
            if clampedWidth != preferredWidth {
                let scale = clampedWidth / width
                let preferredHeight = height * scale
                let clampedHeight = preferredHeight.clamp(constraint.minSize.height, constraint.maxSize.height)
                return CGSize(width: clampedWidth, height: clampedHeight)
            }
            return CGSize(width: clampedWidth, height: clampedSize.height)
        } else {
            return clampedSize
        }
    }
}
