//  Created by Luke Zhao on 8/22/20.

import UIKit


public enum ReuseStrategy {
    case automatic, noReuse
    case key(String)
}

@dynamicMemberLookup
public protocol RenderNode<View> {
    associatedtype View: UIView

    var id: String? { get }
    var animator: Animator? { get }
    var reuseStrategy: ReuseStrategy { get }

    var shouldRenderView: Bool { get }

    /// size of the render node
    var size: CGSize { get }

    /// positions of child render nodes
    var positions: [CGPoint] { get }

    /// child render nodes
    var children: [any RenderNode] { get }

    /// Get indexes of the children that are visible in the given frame
    /// - Parameter frame: Parent component's visible frame in current component's coordinates.
    ///
    /// Discussion: This method is used in the default implementation of `visibleRenderables(in:)`
    /// It won't be called if `visibleRenderables(in:)` is overwritten.
    /// The default implementation for this methods is not optmized and will return all indexes regardless of the frame.
    func visibleIndexes(in frame: CGRect) -> IndexSet

    /// Get renderables that are visible in the given frame
    /// - Parameter frame: Parent component's visible frame in current component's coordinates.
    ///
    /// The default implementation recursively retrives all Renderable from visible children and combines them
    func visibleRenderables(in frame: CGRect) -> [Renderable]

    func makeView() -> View
    func updateView(_ view: View)
}

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

    public func visibleIndexes(in frame: CGRect) -> IndexSet {
        IndexSet(0..<children.count)
    }

    public func visibleRenderables(in frame: CGRect) -> [Renderable] {
        var result = [Renderable]()
        if shouldRenderView, frame.intersects(CGRect(origin: .zero, size: size)) {
            result.append(Renderable(frame: CGRect(origin: .zero, size: size), renderNode: self, fallbackId: "\(type(of: self))"))
        }
        let indexes = visibleIndexes(in: frame)
        for i in indexes {
            let child = children[i]
            let position = positions[i]
            let childFrame = CGRect(origin: position, size: child.size)
            let childVisibleFrame = frame.intersection(childFrame) - position
            let childRenderables = child.visibleRenderables(in: childVisibleFrame).map {
                Renderable(frame: $0.frame + position, renderNode: $0.renderNode, fallbackId: "item-\(i)-\($0.fallbackId)")
            }
            result.append(contentsOf: childRenderables)
        }
        return result
    }
}

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
}

extension RenderNode {
    public func frame(at index: Int) -> CGRect? {
        guard children.count > index, positions.count > index, index >= 0 else { return nil }
        return CGRect(origin: positions[index], size: children[index].size)
    }

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
