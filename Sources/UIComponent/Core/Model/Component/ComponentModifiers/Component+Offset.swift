extension Component {
    /// Applies an offset to the component using the specified `CGPoint`.
    /// - Parameter offset: The `CGPoint` value to apply as an offset.
    /// - Returns: A component offset by the specified point.
    public func offset(_ offset: CGPoint) -> some Component {
        Offset(content: self, offset: offset)
    }

    /// Applies an offset to the component using separate x and y values.
    /// - Parameters:
    ///   - x: The horizontal offset.
    ///   - y: The vertical offset.
    /// - Returns: A component offset by the specified x and y values.
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> some Component {
        Offset(content: self, offset: CGPoint(x: x, y: y))
    }

    /// Applies a dynamic offset to the component based on constraints at layout time.
    /// - Parameter offsetProvider: A closure that provides a `CGPoint` based on the given `Constraint`.
    /// - Returns: A component that dynamically adjusts its offset based on the provided point.
    public func offset(_ offsetProvider: @escaping (Constraint) -> CGPoint) -> some Component {
        DynamicOffset(content: self, offsetProvider: offsetProvider)
    }
}
