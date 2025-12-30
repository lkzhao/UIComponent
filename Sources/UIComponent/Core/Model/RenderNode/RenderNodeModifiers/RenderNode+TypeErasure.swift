extension RenderNode {
    /// Erases the type of the render node and wraps it in a type-erasing `AnyRenderNode`.
    /// - Returns: An `AnyRenderNode` instance.
    public func eraseToAnyRenderNode() -> AnyRenderNode {
        AnyRenderNode(self)
    }

    /// Erases the type of the render node that has a specific view type and wraps it in a type-erasing `AnyRenderNodeOfView`.
    /// - Returns: An `AnyRenderNodeOfView` instance that holds a type-erased render node of the specific view type.
    public func eraseToAnyRenderNodeOfView() -> AnyRenderNodeOfView<View> {
        AnyRenderNodeOfView(self)
    }
}
