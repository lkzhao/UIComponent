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
    /// The default implementation for this methods is not optmized and will return all indexes regardless of the frame.
    func visibleIndexes(in frame: CGRect) -> any Collection<Int>

    /// Returns the visible frame given the parent visible frame.
    ///
    /// - Parameter frame: The parent visible frame.
    ///
    /// The default implementation will return the parent visible frame. This method is used by the VisibleFrameInset components to adjust the visible frame.
    func visibleFrame(in frame: CGRect) -> CGRect

    /// Creates a new view instance for this render node.
    func makeView() -> View

    /// Updates the provided view with the current state of this render node.
    ///
    /// - Parameter view: The view to update.
    func updateView(_ view: View)
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
    public func visibleFrame(in frame: CGRect) -> CGRect {
        frame
    }
}

// MARK: - Internal methods

extension RenderNode {
    internal func _makeView() -> UIView {
        switch reuseStrategy {
        case .automatic:
            return ReuseManager.shared.dequeue(identifier: "\(type(of: self))", makeView())
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
        let frame = visibleFrame(in: frame)
        if shouldRenderView, frame.intersects(CGRect(origin: .zero, size: size)) {
            result.append(Renderable(frame: CGRect(origin: .zero, size: size), renderNode: self, fallbackId: "\(type(of: self))"))
        }
        let indexes = visibleIndexes(in: frame)
        for i in indexes {
            let child = children[i]
            let position = positions[i]
            let childFrame = CGRect(origin: position, size: child.size)
            let childVisibleFrame = frame.intersection(childFrame) - position
            let childRenderables = child._visibleRenderables(in: childVisibleFrame).map {
                Renderable(frame: $0.frame + position, renderNode: $0.renderNode, fallbackId: "item-\(i)-\($0.fallbackId)")
            }
            result.append(contentsOf: childRenderables)
        }
        return result
    }
}
