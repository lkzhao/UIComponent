//  Created by Luke Zhao on 8/22/20.

import UIKit

/// Render nodes are responsible for storing the layout information, generating UIView for rendering, and updating UIView upon reload.
@dynamicMemberLookup
public protocol RenderNode<View> {
    /// The `UIView` class that this render node represents.
    associatedtype View: UIView

    /// A Boolean value indicating whether the render node should render its own view.
    var shouldRenderView: Bool { get }

    /// A unique identifier for the render node.
    var id: String? { get }

    /// An animator responsible for animating view changes.
    var animator: Animator? { get }

    /// The strategy to use when reusing views.
    var reuseStrategy: ReuseStrategy { get }

    /// The default reuse key for the render node. This key will be used when reuseStrategy is set to .automatic.
    /// This will also be used as fallbackId for structured identity when id is not set.
    var defaultReuseKey: String { get }

    /// The size of the render node.
    var size: CGSize { get }

    /// The positions of child render nodes relative to this node's origin.
    var positions: [CGPoint] { get }

    /// The child render nodes of this node.
    var children: [any RenderNode] { get }

    /// Returns the indexes of the children that are visible within the given frame.
    ///
    /// - Parameter frame: The frame within which to determine visibility of children.
    /// - Returns: The indexes of the children that are visible within the given frame.
    ///
    /// This method is used in the default implementation of `visibleRenderables(in:)`.
    /// It won't be called if `visibleRenderables(in:)` is overwritten.
    /// The default implementation for this methods is not optmized and will return all indexes regardless of the frame.
    func visibleIndexes(in frame: CGRect) -> any Collection<Int>

    /// Returns the render nodes that are visible within the given frame.
    ///
    /// - Parameter frame: The frame within which to determine visibility of renderables.
    /// - Returns: The render nodes that are visible within the given frame. The objects to return are `RenderNodeChild` which contains
    ///            the child render node, the position relative to the parent, and the index of the child (for structure identity only, not used to access `children` or `positions`).
    ///
    /// The default implementation calls ``RenderNode/visibleIndexes(in:)-1jtpe`` to get the visible childrens. And return the corresponding RenderNodeChild by combining data from `children` and `positions`.
    func visibleChildren(in frame: CGRect) -> [RenderNodeChild]

    /// Creates a new view instance for this render node.
    func makeView() -> View

    /// Updates the provided view with the current state of this render node.
    ///
    /// - Parameter view: The view to update.
    func updateView(_ view: View)


    /// Method called before `visibleChildren(in:)` to adjust the visible frame.
    func adjustVisibleFrame(frame: CGRect) -> CGRect
}

// MARK: - Helper methods

extension RenderNode {
    /// Returns the frame of the child render node at the specified index.
    ///
    /// - Parameter index: The index of the child render node.
    /// - Returns: The frame of the child render node if the index is valid, otherwise nil.
    public func frame(at index: Int) -> CGRect? {
        guard children.count > index, positions.count > index, index >= 0 else { return nil }
        return CGRect(origin: positions[index], size: children[index].size)
    }

    /// Returns the frame of the render node with the specified identifier.
    ///
    /// - Parameter id: The identifier of the render node.
    /// - Returns: The frame of the render node if found, otherwise nil.
    public func frame(id: String) -> CGRect? {
        if self.id == id {
            return CGRect(origin: .zero, size: size)
        }
        for (index, child) in children.enumerated() {
            if let frame = child.frame(id: id) {
                return frame + positions[index]
            }
        }
        return nil
    }

    /// Returns the render node with the specified identifier.
    ///
    /// - Parameter id: The identifier of the render node.
    /// - Returns: The render node if found, otherwise nil.
    public func renderNode(id: String) -> (any RenderNode)? {
        if self.id == id {
            return self
        }
        for child in children {
            if let node = child.renderNode(id: id) {
                return node
            }
        }
        return nil
    }
}

// MARK: - Default implementation

extension RenderNode {
    public var id: String? { nil }
    public var animator: Animator? { nil }
    public var reuseStrategy: ReuseStrategy { .automatic }
    public var defaultReuseKey: String { "\(type(of: self))" }
    public var shouldRenderView: Bool { children.isEmpty }

    public func makeView() -> View {
        View()
    }
    public func updateView(_ view: View) {

    }

    public var children: [any RenderNode] { [] }
    public var positions: [CGPoint] { [] }

    public func visibleIndexes(in frame: CGRect) -> any Collection<Int> {
        IndexSet(0..<children.count)
    }

    public func visibleChildren(in frame: CGRect) -> [RenderNodeChild] {
        var result = [RenderNodeChild]()
        for i in visibleIndexes(in: frame) {
            let child = children[i]
            let position = positions[i]
            let renderable = RenderNodeChild(renderNode: child, position: position, index: i)
            result.append(renderable)
        }
        return result
    }

    public func adjustVisibleFrame(frame: CGRect) -> CGRect {
        frame
    }
}

// MARK: - Internal methods

extension RenderNode {
    internal func _makeView() -> UIView {
        switch reuseStrategy {
        case .automatic:
            return ReuseManager.shared.dequeue(identifier: defaultReuseKey, makeView())
        case .noReuse:
            return makeView()
        case .key(let key):
            return ReuseManager.shared.dequeue(identifier: key, makeView())
        }
    }

    internal func _updateView(_ view: UIView) {
        guard let view = view as? View else { return }
        return updateView(view)
    }

    internal func _visibleRenderables(in frame: CGRect) -> [Renderable] {
        var result = [Renderable]()
        if shouldRenderView {
            result.append(Renderable(frame: CGRect(origin: .zero, size: size), renderNode: self, fallbackId: defaultReuseKey))
        }
        let frame = adjustVisibleFrame(frame: frame)
        let children = visibleChildren(in: frame)
        for child in children {
            let childFrame = CGRect(origin: child.position, size: child.renderNode.size)
            let childVisibleFrame = frame.intersection(childFrame) - child.position
            let childRenderables = child.renderNode._visibleRenderables(in: childVisibleFrame).map {
                Renderable(frame: $0.frame + child.position, renderNode: $0.renderNode, fallbackId: "item-\(child.index)-\($0.fallbackId)")
            }
            result.append(contentsOf: childRenderables)
        }
        return result
    }
}
