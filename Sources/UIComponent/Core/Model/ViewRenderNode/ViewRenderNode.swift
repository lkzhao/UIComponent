//  Created by Luke Zhao on 8/22/20.

import UIKit
@_implementationOnly import BaseToolbox

public enum ReuseStrategy {
    case automatic, noReuse
    case key(String)
}

@dynamicMemberLookup
public protocol ViewRenderNode<View>: AnyRenderNode {
    associatedtype View: UIView

    var id: String? { get }
    var keyPath: String { get }
    var animator: Animator? { get }
    var reuseStrategy: ReuseStrategy { get }

    func makeView() -> View
    func updateView(_ view: View)
}

public class NeverView: UIView {

}

extension ViewRenderNode {
    public var id: String? { nil }
    public var animator: Animator? { nil }
    public var keyPath: String { "\(type(of: self))" }
    public var reuseStrategy: ReuseStrategy { .automatic }
    public func makeView() -> View {
        View()
    }
    public func updateView(_ view: View) {

    }
    public func visibleRenderables(in frame: CGRect) -> [Renderable] {
        if View.self is NeverView.Type {
            var result = [Renderable]()
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
        } else {
            let childFrame = CGRect(origin: .zero, size: size)
            if frame.intersects(childFrame) {
                return [ViewRenderable(renderNode: self)]
            }
            return []
        }
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
