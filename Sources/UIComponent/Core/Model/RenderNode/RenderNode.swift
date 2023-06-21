//  Created by Luke Zhao on 8/22/20.

import UIKit
@_implementationOnly import BaseToolbox

public enum ReuseStrategy {
    case automatic, noReuse
    case key(String)
}

@dynamicMemberLookup
public protocol RenderNode<View> {
    associatedtype View: UIView

    var id: String? { get }
    var keyPath: String { get }
    var animator: Animator? { get }
    var reuseStrategy: ReuseStrategy { get }

    var shouldRender: Bool { get }

    /// size of the render node
    var size: CGSize { get }

    /// positions of child render nodes
    var positions: [CGPoint] { get }

    /// child render nodes
    var children: [any RenderNode] { get }

    /// Get indexes of the children that are visible in the given frame
    /// - Parameter frame: Parent component's visible frame in current component's coordinates.
    func visibleIndexes(in frame: CGRect) -> IndexSet

    func makeView() -> View
    func updateView(_ view: View)
}

extension RenderNode {
    public var id: String? { nil }
    public var animator: Animator? { nil }
    public var keyPath: String { "\(type(of: self))" }
    public var reuseStrategy: ReuseStrategy { .automatic }
    public var shouldRender: Bool { children.isEmpty }

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
}

extension RenderNode {
    internal func visibleRenderables(in frame: CGRect) -> [Renderable] {
        var result = [Renderable]()
        if shouldRender, frame.intersects(CGRect(origin: .zero, size: size)) {
            result.append(ViewRenderable(renderNode: self))
        }
        let indexes = visibleIndexes(in: frame)
        for i in indexes {
            let child = children[i]
            let position = positions[i]
            let childFrame = CGRect(origin: position, size: child.size)
            let childVisibleFrame = frame.intersection(childFrame) - position
            let childRenderables = child.visibleRenderables(in: childVisibleFrame).map {
                OffsetRenderable(renderable: $0, offset: position, index: i)
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
        guard let size = children.get(index)?.size, let position = positions.get(index) else { return nil }
        return CGRect(origin: position, size: size)
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
}
