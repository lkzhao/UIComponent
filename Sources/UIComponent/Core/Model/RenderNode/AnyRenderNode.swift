//  Created by Luke Zhao on 1/14/24.

/// A type-erased wrapper for any `RenderNode`.
public struct AnyRenderNode: RenderNode {
    public typealias View = PlatformView
    /// The underlying `RenderNode` instance being type-erased.
    public let erasing: any RenderNode
    private let _makeView: () -> PlatformView
    private let _updateView: (PlatformView) -> Void
    
    /// Initializes a new `AnyRenderNode` with the provided `RenderNode`.
    ///
    /// - Parameter erasing: The `RenderNode` instance to type-erase.
    public init<R: RenderNode>(_ erasing: R) {
        self.erasing = erasing
        self._makeView = { erasing._makeView() }
        self._updateView = { view in erasing._updateView(view) }
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
    public func updateView(_ view: PlatformView) {
        _updateView(view)
    }
    public func makeView() -> PlatformView {
        _makeView()
    }
    public func contextValue(_ key: RenderNodeContextKey) -> Any? {
        erasing.contextValue(key)
    }
}

/// A type-erased wrapper for any `RenderNode` specialized for a specific `UIView` subclass.
public struct AnyRenderNodeOfView<View: PlatformView>: RenderNode {
    /// The underlying `RenderNode` instance being type-erased.
    public let erasing: any RenderNode
    private let _makeView: () -> View
    private let _updateView: (View) -> Void
    
    /// Initializes a new `AnyRenderNodeOfView` with the provided `RenderNode`.
    ///
    /// - Parameter erasing: The `RenderNode` instance to type-erase.
    public init<R: RenderNode>(_ erasing: R) where R.View == View {
        self.erasing = erasing
        self._makeView = { erasing._makeView() as! View }
        self._updateView = { view in erasing._updateView(view) }
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
        _updateView(view)
    }
    public func makeView() -> View {
        _makeView()
    }
    public func contextValue(_ key: RenderNodeContextKey) -> Any? {
        erasing.contextValue(key)
    }
}
