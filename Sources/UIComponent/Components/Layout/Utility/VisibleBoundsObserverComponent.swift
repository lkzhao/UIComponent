//  Created by Luke Zhao on 10/10/22.

import Foundation

public struct VisibleBoundsObserverComponent: Component {
    let child: Component
    let onVisibleBoundsChanged: (CGSize, CGRect) -> ()
    public func layout(_ constraint: Constraint) -> RenderNode {
        VisibleBoundsObserverRenderNode(child: child.layout(constraint), onVisibleBoundsChanged: onVisibleBoundsChanged)
    }
}

struct VisibleBoundsObserverRenderNode: RenderNode {
    let child: RenderNode
    let onVisibleBoundsChanged: (CGSize, CGRect) -> ()
    var size: CGSize {
        child.size
    }
    var children: [RenderNode] {
        [child]
    }
    var positions: [CGPoint] {
        [.zero]
    }
    func visibleIndexes(in frame: CGRect) -> IndexSet {
        onVisibleBoundsChanged(size, frame)
        return [0]
    }
}
