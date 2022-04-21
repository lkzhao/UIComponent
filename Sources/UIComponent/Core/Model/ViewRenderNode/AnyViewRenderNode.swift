//  Created by Luke Zhao on 8/22/20.

import UIKit

public protocol AnyViewRenderNode: RenderNode {
    var id: String? { get }
    var keyPath: String { get }
    var animator: Animator? { get }
    func _makeView() -> Any
    func _updateView(_ view: Any)
}

extension AnyViewRenderNode {
    public var id: String? { nil }
    public var animator: Animator? { nil }
    public var keyPath: String { "\(type(of: self))" }

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
