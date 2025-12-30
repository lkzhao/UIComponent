//  Created by Luke Zhao on 1/14/24.

/// A type-erased wrapper for any `RenderNode`.
public struct AnyRenderNode: RenderNode {
    /// The underlying `RenderNode` instance being type-erased.
    public let erasing: any RenderNode
    
    /// Initializes a new `AnyRenderNode` with the provided `RenderNode`.
    ///
    /// - Parameter erasing: The `RenderNode` instance to type-erase.
    public init(_ erasing: any RenderNode) {
        self.erasing = erasing
    }

    // MARK: - RenderNode methods

    public var structureTypeId: String {
        "AnyRenderNode<\(erasing.structureTypeId)>"
    }
    public var size: CGSize {
        erasing.size
    }
    public var positions: [CGPoint] {
        erasing.positions
    }
    public var children: [any RenderNode] {
        erasing.children
    }
    public var shouldRenderView: Bool {
        erasing.shouldRenderView
    }
    public func visibleChildren(in frame: CGRect) -> [RenderNodeChild] {
        erasing.visibleChildren(in: frame)
    }
    public func adjustVisibleFrame(frame: CGRect) -> CGRect {
        erasing.adjustVisibleFrame(frame: frame)
    }
    public func updateView(_ view: UIView) {
        erasing._updateView(view)
    }
    public func makeView() -> UIView {
        erasing.makeView()
    }
    public func contextValue(_ key: RenderNodeContextKey) -> Any? {
        erasing.contextValue(key)
    }
}

/// A type-erased wrapper for any `RenderNode` specialized for a specific `UIView` subclass.
public struct AnyRenderNodeOfView<View: UIView>: RenderNode {
    /// The underlying `RenderNode` instance being type-erased.
    public let erasing: any RenderNode
    
    /// Initializes a new `AnyRenderNodeOfView` with the provided `RenderNode`.
    ///
    /// - Parameter erasing: The `RenderNode` instance to type-erase.
    public init(_ erasing: any RenderNode) {
        self.erasing = erasing
    }

    // MARK: - RenderNode methods

    public var structureTypeId: String {
        "AnyRenderNodeOfView<\(erasing.structureTypeId)>"
    }
    public var size: CGSize {
        erasing.size
    }
    public var positions: [CGPoint] {
        erasing.positions
    }
    public var children: [any RenderNode] {
        erasing.children
    }
    public var shouldRenderView: Bool {
        erasing.shouldRenderView
    }
    public func visibleChildren(in frame: CGRect) -> [RenderNodeChild] {
        erasing.visibleChildren(in: frame)
    }
    public func adjustVisibleFrame(frame: CGRect) -> CGRect {
        erasing.adjustVisibleFrame(frame: frame)
    }
    public func updateView(_ view: View) {
        erasing._updateView(view)
    }
    public func makeView() -> View {
        erasing.makeView() as! View
    }
    public func contextValue(_ key: RenderNodeContextKey) -> Any? {
        erasing.contextValue(key)
    }
}
