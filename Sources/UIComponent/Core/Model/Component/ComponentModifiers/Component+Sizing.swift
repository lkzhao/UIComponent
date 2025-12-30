extension Component {
    /// Adjusts the size of the component using specified strategies for width and height.
    /// - Parameters:
    ///   - width: A `SizeStrategy` value that determines the width sizing strategy. Defaults to `.fit`.
    ///   - height: A `SizeStrategy` value that determines the height sizing strategy. Defaults to `.fit`.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden size constraints.
    public func size(width: SizeStrategy = .fit, height: SizeStrategy = .fit) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: SizeStrategyConstraintTransformer(width: width, height: height))
    }

    /// Sets an absolute width and uses a specified strategy for the height of the component.
    /// - Parameters:
    ///   - width: A `CGFloat` value that specifies the absolute width for the component.
    ///   - height: A `SizeStrategy` value that determines the height sizing strategy. Defaults to `.fit`.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden width and height constraints.
    public func size(width: CGFloat, height: SizeStrategy = .fit) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: height))
    }

    /// Uses a specified strategy for the width and sets an absolute height for the component.
    /// - Parameters:
    ///   - width: A `SizeStrategy` value that determines the width sizing strategy. Defaults to `.fit`.
    ///   - height: A `CGFloat` value that specifies the absolute height for the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden width and height constraints.
    public func size(width: SizeStrategy = .fit, height: CGFloat) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: SizeStrategyConstraintTransformer(width: width, height: .absolute(height)))
    }

    /// Sets an absolute size for the component.
    /// - Parameter size: A `CGSize` value that specifies the absolute size for the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden size constraints.
    public func size(_ size: CGSize) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(size.width), height: .absolute(size.height)))
    }

    /// Sets an absolute size for the component.
    /// - Parameter size: A `CGFloat` value that specifies the absolute size for the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden size constraints.
    public func size(_ size: CGFloat) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(size), height: .absolute(size)))
    }

    /// Sets an absolute size for the component based on the constraint.
    /// - Parameter sizeProvider: A closure that takes a `Constraint` and returns a size.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden size.
    public func size(_ sizeProvider: @escaping (Constraint) -> CGSize) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: BlockConstraintTransformer(block: {
            let size = sizeProvider($0)
            return Constraint(tightSize: size)
        }))
    }

    /// Sets an absolute size for the component based on the max size constraint.
    /// - Parameter sizeProvider: A closure that takes a max size and returns a modified size.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden size.
    public func size(_ sizeProvider: @escaping (CGSize) -> CGSize) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: BlockConstraintTransformer(block: {
            let size = sizeProvider($0.maxSize)
            return Constraint(tightSize: size)
        }))
    }

    /// Sets an absolute size for the component.
    /// - Parameters:
    ///   - width: A `CGFloat` value that specifies the absolute width for the component.
    ///   - height: A `CGFloat` value that specifies the absolute height for the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden width and height constraints.
    public func size(width: CGFloat, height: CGFloat) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: SizeStrategyConstraintTransformer(width: .absolute(width), height: .absolute(height)))
    }

    /// Applies a custom constraint transformation to the component.
    /// - Parameter constraintComponent: A closure that takes a `Constraint` and returns a modified `Constraint`.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with custom constraints.
    public func constraint(_ constraintComponent: @escaping (Constraint) -> Constraint) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: BlockConstraintTransformer(block: constraintComponent))
    }

    /// Overrides the component's constraints with the specified constraints.
    /// - Parameter constraint: A `Constraint` object that specifies the constraints to be applied to the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with overridden constraints.
    public func constraint(_ constraint: Constraint) -> ConstraintOverrideComponent<Self> {
        ConstraintOverrideComponent(content: self, transformer: PassThroughConstraintTransformer(constraint: constraint))
    }

    /// Removes the upper bound on the component's width, allowing it to grow indefinitely.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with an unbounded width.
    public func unboundedWidth() -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: .infinity, height: c.maxSize.height))
        }
    }

    /// Removes the upper bound on the component's height, allowing it to grow indefinitely.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with an unbounded height.
    public func unboundedHeight() -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: c.maxSize.width, height: .infinity))
        }
    }

    /// Removes the constraint on the component's width.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with a unconstrainted width.
    public func ignoreWidthConstraint() -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: CGSize(width: -.infinity, height: c.minSize.height),
                       maxSize: CGSize(width: .infinity, height: c.maxSize.height))
        }
    }

    /// Removes the constraint on the component's height.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with a unconstrainted height.
    public func ignoreHeightConstraint() -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: CGSize(width: c.minSize.width, height: -.infinity),
                       maxSize: CGSize(width: c.maxSize.width, height: .infinity))
        }
    }

    /// Sets the maximum size for the component.
    /// - Parameters:
    ///   - width: A `CGFloat` value that sets the maximum width. Defaults to `.infinity`.
    ///   - height: A `CGFloat` value that sets the maximum height. Defaults to `.infinity`.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with maximum size constraints.
    public func maxSize(width: CGFloat = .infinity, height: CGFloat = .infinity) -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: c.minSize, maxSize: CGSize(width: min(width, c.maxSize.width), height: min(height, c.maxSize.height)))
        }
    }

    /// Sets the minimum size for the component.
    /// - Parameters:
    ///   - width: A `CGFloat` value that sets the minimum width. Defaults to `-.infinity`.
    ///   - height: A `CGFloat` value that sets the minimum height. Defaults to `-.infinity`.
    /// - Returns: A `ConstraintOverrideComponent` that represents the modified component with minimum size constraints.
    public func minSize(width: CGFloat = -.infinity, height: CGFloat = -.infinity) -> ConstraintOverrideComponent<Self> {
        constraint { c in
            Constraint(minSize: CGSize(width: max(width, c.minSize.width), height: max(height, c.minSize.height)), maxSize: c.maxSize)
        }
    }

    /// Applies the `.fit` size strategy to both width and height of the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the component with `.fit` size strategy applied.
    public func fit() -> ConstraintOverrideComponent<Self> {
        size(width: .fit, height: .fit)
    }

    /// Applies the `.fill` size strategy to both width and height of the component.
    /// - Returns: A `ConstraintOverrideComponent` that represents the component with `.fill` size strategy applied.
    public func fill() -> ConstraintOverrideComponent<Self> {
        size(width: .fill, height: .fill)
    }
}
