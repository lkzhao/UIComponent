//  Created by Luke Zhao on 8/22/20.

import UIKit

public enum ReuseStrategy {
    case automatic, noReuse
    case key(String)
}

@dynamicMemberLookup
public protocol ViewRenderNode<View>: RenderNode {
    associatedtype View: UIView

    var id: String? { get }
    var keyPath: String { get }
    var animator: Animator? { get }
    var reuseStrategy: ReuseStrategy { get }

    func makeView() -> View
    func updateView(_ view: View)
}

extension ViewRenderNode {
    public var id: String? { nil }
    public var animator: Animator? { nil }
    public var keyPath: String { "\(type(of: self))" }
    public var reuseStrategy: ReuseStrategy { .automatic }
    public func makeView() -> View {
        View()
    }
    public func visibleRenderables(in frame: CGRect) -> [Renderable] {
        let childFrame = CGRect(origin: .zero, size: size)
        if frame.intersects(childFrame) {
            return [ViewRenderable(renderNode: self)]
        }
        return []
    }
}

extension ViewRenderNode {
    public func _makeView() -> Any {
        switch reuseStrategy {
        case .automatic:
            return ReuseManager.shared.dequeue(identifier: "\(type(of: self))", makeView())
        case .noReuse:
            return makeView()
        case .key(let key):
            return ReuseManager.shared.dequeue(identifier: key, makeView())
        }
    }
    public func _updateView(_ view: Any) {
        guard let view = view as? View else { return }
        return updateView(view)
    }
}
