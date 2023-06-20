//  Created by Luke Zhao on 10/10/22.

import Foundation

public struct VisibleBoundsObserverComponent: Component {
    let child: any Component
    let onVisibleBoundsChanged: (CGSize, CGRect) -> ()
    public func layout(_ constraint: Constraint) -> some RenderNode {
        VisibleBoundsObserverRenderNode(child: child.layout(constraint), onVisibleBoundsChanged: onVisibleBoundsChanged)
    }
}

struct VisibleBoundsObserverRenderNode: RenderNode {
    typealias View = NeverView

    let child: any RenderNode
    let onVisibleBoundsChanged: (CGSize, CGRect) -> ()
    var size: CGSize {
        child.size
    }
    var children: [any RenderNode] {
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
