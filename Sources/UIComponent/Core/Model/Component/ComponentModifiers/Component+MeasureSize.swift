extension Component {
    /// Use the view's sizeThatFits to measure its size.
    /// - Parameter key: A key used to cache measured size in the hosting component engine.
    /// - Returns: A `MeasureSizeComponent` wrapping this component.
    public func measureSize(key: String) -> MeasureSizeComponent<Self> {
        MeasureSizeComponent(key: key, content: self)
    }
}
