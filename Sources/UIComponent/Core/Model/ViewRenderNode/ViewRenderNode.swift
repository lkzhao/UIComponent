//  Created by Luke Zhao on 8/22/20.

import UIKit

public protocol UIComponentRenderableView {
    init()
}
extension UIView: UIComponentRenderableView {}

public enum ReuseStrategy {
    case automatic, noReuse
    case key(String)
}

@dynamicMemberLookup
public protocol ViewRenderNode<View>: RenderNode {
    associatedtype View: UIComponentRenderableView
    
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
            return [
                Renderable(
                    id: id,
                    keyPath: keyPath,
                    animator: animator,
                    renderNode: self,
                    frame: childFrame
                )
            ]
        }
        return []
    }
}

extension ViewRenderNode {
    internal func _makeView() -> Any {
        if View.self is UIView.Type {
            switch reuseStrategy {
            case .automatic:
                return ReuseManager.shared.dequeue(identifier: "\(type(of: self))", makeView() as! UIView)
            case .noReuse:
                return makeView()
            case .key(let key):
                return ReuseManager.shared.dequeue(identifier: key, makeView() as! UIView)
            }
        }
        return makeView()
    }
    internal func _updateView(_ view: Any) {
        guard let view = view as? View else { return }
        return updateView(view)
    }
}
