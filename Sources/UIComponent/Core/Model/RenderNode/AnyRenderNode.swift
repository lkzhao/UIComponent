//  Created by Luke Zhao on 1/14/24.

import UIKit

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

    public var id: String? {
        erasing.id
    }
    public var animator: Animator? {
        erasing.animator
    }
    public var reuseStrategy: ReuseStrategy {
        erasing.reuseStrategy
    }
    public var shouldRenderView: Bool {
        erasing.shouldRenderView
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
    public func visibleIndexes(in frame: CGRect) -> IndexSet {
        erasing.visibleIndexes(in: frame)
    }
    public func updateView(_ view: UIView) {
        erasing._updateView(view)
    }
    public func makeView() -> UIView {
        erasing._makeView()
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

    public var id: String? {
        erasing.id
    }
    public var animator: Animator? {
        erasing.animator
    }
    public var reuseStrategy: ReuseStrategy {
        erasing.reuseStrategy
    }
    public var shouldRenderView: Bool {
        erasing.shouldRenderView
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
    public func visibleIndexes(in frame: CGRect) -> IndexSet {
        erasing.visibleIndexes(in: frame)
    }
    public func updateView(_ view: View) {
        erasing._updateView(view)
    }
    public func makeView() -> View {
        erasing._makeView() as! View
    }
}
