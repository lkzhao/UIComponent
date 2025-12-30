extension Component {
    // MARK: - Inset modifiers

    /// Applies uniform padding to all edges of the component.
    /// - Parameter amount: The padding amount to be applied to all edges.
    /// - Returns: A component wrapped with the specified amount of padding.
    public func inset(_ amount: CGFloat) -> some Component {
        Insets(content: self, insets: PlatformEdgeInsets(top: amount, left: amount, bottom: amount, right: amount))
    }

    /// Applies horizontal and vertical padding to the component.
    /// - Parameters:
    ///   - h: The horizontal padding amount.
    ///   - v: The vertical padding amount.
    /// - Returns: A component wrapped with the specified horizontal and vertical padding.
    public func inset(h: CGFloat, v: CGFloat) -> some Component {
        Insets(content: self, insets: PlatformEdgeInsets(top: v, left: h, bottom: v, right: h))
    }

    /// Applies vertical and horizontal padding to the component.
    /// - Parameters:
    ///   - v: The vertical padding amount.
    ///   - h: The horizontal padding amount.
    /// - Returns: A component wrapped with the specified vertical and horizontal padding.
    public func inset(v: CGFloat, h: CGFloat) -> some Component {
        Insets(content: self, insets: PlatformEdgeInsets(top: v, left: h, bottom: v, right: h))
    }

    /// Applies horizontal padding to the component.
    /// - Parameter h: The horizontal padding amount.
    /// - Returns: A component wrapped with the specified horizontal padding.
    public func inset(h: CGFloat) -> some Component {
        Insets(content: self, insets: PlatformEdgeInsets(top: 0, left: h, bottom: 0, right: h))
    }

    /// Applies vertical padding to the component.
    /// - Parameter v: The vertical padding amount.
    /// - Returns: A component wrapped with the specified vertical padding.
    public func inset(v: CGFloat) -> some Component {
        Insets(content: self, insets: PlatformEdgeInsets(top: v, left: 0, bottom: v, right: 0))
    }

    /// Applies padding to the component with specific values for each edge.
    /// - Parameters:
    ///   - top: The padding amount for the top edge.
    ///   - left: The padding amount for the left edge.
    ///   - bottom: The padding amount for the bottom edge.
    ///   - right: The padding amount for the right edge.
    /// - Returns: A component wrapped with the specified edge padding.
    public func inset(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> some Component {
        Insets(content: self, insets: PlatformEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }

    /// Applies padding to the component with a specific value for the top edge and uniform padding for the remaining edges.
    /// - Parameters:
    ///   - top: The padding amount for the top edge.
    ///   - rest: The padding amount for the remaining edges.
    /// - Returns: A component wrapped with the specified padding.
    public func inset(top: CGFloat, rest: CGFloat) -> some Component {
        Insets(content: self, insets: PlatformEdgeInsets(top: top, left: rest, bottom: rest, right: rest))
    }

    /// Applies padding to the component with a specific value for the left edge and uniform padding for the remaining edges.
    /// - Parameters:
    ///   - left: The padding amount for the left edge.
    ///   - rest: The padding amount for the remaining edges.
    /// - Returns: A component wrapped with the specified padding.
    public func inset(left: CGFloat, rest: CGFloat) -> some Component {
        Insets(content: self, insets: PlatformEdgeInsets(top: rest, left: left, bottom: rest, right: rest))
    }

    /// Applies padding to the component with a specific value for the bottom edge and uniform padding for the remaining edges.
    /// - Parameters:
    ///   - bottom: The padding amount for the bottom edge.
    ///   - rest: The padding amount for the remaining edges.
    /// - Returns: A component wrapped with the specified padding.
    public func inset(bottom: CGFloat, rest: CGFloat) -> some Component {
        Insets(content: self, insets: PlatformEdgeInsets(top: rest, left: rest, bottom: bottom, right: rest))
    }

    /// Applies padding to the component with a specific value for the right edge and uniform padding for the remaining edges.
    /// - Parameters:
    ///   - right: The padding amount for the right edge.
    ///   - rest: The padding amount for the remaining edges.
    /// - Returns: A component wrapped with the specified padding.
    public func inset(right: CGFloat, rest: CGFloat) -> some Component {
        Insets(content: self, insets: PlatformEdgeInsets(top: rest, left: rest, bottom: rest, right: right))
    }

    /// Applies padding to the component using the specified `UIEdgeInsets`.
    /// - Parameter insets: The `UIEdgeInsets` value to apply as padding.
    /// - Returns: A component wrapped with the specified padding.
    public func inset(_ insets: PlatformEdgeInsets) -> some Component {
        Insets(content: self, insets: insets)
    }

    /// Applies dynamic padding to the component based on constraints at layout time.
    /// - Parameter insetProvider: A closure that provides `UIEdgeInsets` based on the given `Constraint`.
    /// - Returns: A component that dynamically adjusts its padding based on the provided insets.
    public func inset(_ insetProvider: @escaping (Constraint) -> PlatformEdgeInsets) -> some Component {
        DynamicInsets(content: self, insetProvider: insetProvider)
    }

    // MARK: - Visible insets modifiers

    /// Applies uniform visible frame insets to the component.
    /// - Parameter amount: The padding amount for all edges.
    /// - Returns: A component wrapped with the specified visible frame insets.
    public func visibleInset(_ amount: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(content: self, insets: PlatformEdgeInsets(top: amount, left: amount, bottom: amount, right: amount))
    }

    /// Applies visible frame insets to the component with specified horizontal and vertical padding.
    /// - Parameters:
    ///   - h: The padding amount for the horizontal edges.
    ///   - v: The padding amount for the vertical edges.
    /// - Returns: A component wrapped with the specified visible frame insets.
    public func visibleInset(h: CGFloat, v: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(content: self, insets: PlatformEdgeInsets(top: v, left: h, bottom: v, right: h))
    }

    /// Applies visible frame insets to the component with specified vertical and horizontal padding.
    /// - Parameters:
    ///   - v: The padding amount for the vertical edges.
    ///   - h: The padding amount for the horizontal edges.
    /// - Returns: A component wrapped with the specified visible frame insets.
    public func visibleInset(v: CGFloat, h: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(content: self, insets: PlatformEdgeInsets(top: v, left: h, bottom: v, right: h))
    }

    /// Applies visible frame insets to the component with specified horizontal padding.
    /// - Parameter h: The padding amount for the horizontal edges.
    /// - Returns: A component wrapped with the specified visible frame insets.
    public func visibleInset(h: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(content: self, insets: PlatformEdgeInsets(top: 0, left: h, bottom: 0, right: h))
    }

    /// Applies visible frame insets to the component with specified vertical padding.
    /// - Parameter v: The padding amount for the vertical edges.
    /// - Returns: A component wrapped with the specified visible frame insets.
    public func visibleInset(v: CGFloat) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(content: self, insets: PlatformEdgeInsets(top: v, left: 0, bottom: v, right: 0))
    }

    /// Applies visible frame insets to the component using the specified `UIEdgeInsets`.
    /// - Parameter insets: The `UIEdgeInsets` value to apply as visible frame insets.
    /// - Returns: A component wrapped with the specified visible frame insets.
    public func visibleInset(_ insets: PlatformEdgeInsets) -> VisibleFrameInsets<Self> {
        VisibleFrameInsets(content: self, insets: insets)
    }

    /// Applies dynamic visible frame insets to the component based on constraints at layout time.
    /// - Parameter insetProvider: A closure that provides `UIEdgeInsets` based on the given `CGRect`.
    /// - Returns: A component that dynamically adjusts its visible frame insets based on the provided insets.
    public func visibleInset(_ insetProvider: @escaping (CGRect) -> PlatformEdgeInsets) -> DynamicVisibleFrameInset<Self> {
        DynamicVisibleFrameInset(content: self, insetProvider: insetProvider)
    }
}
