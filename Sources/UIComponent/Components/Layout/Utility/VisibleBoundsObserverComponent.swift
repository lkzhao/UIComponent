//  Created by Luke Zhao on 10/10/22.

import UIKit

public struct VisibleBoundsObserverComponent<Content: Component>: Component {
    let child: Content
    let onVisibleBoundsChanged: (CGSize, CGRect) -> ()
    public func layout(_ constraint: Constraint) -> VisibleBoundsObserverRenderNode<Content.R> {
        VisibleBoundsObserverRenderNode(content: child.layout(constraint), onVisibleBoundsChanged: onVisibleBoundsChanged)
    }
}

public struct VisibleBoundsObserverRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let onVisibleBoundsChanged: (CGSize, CGRect) -> ()

    public func visibleIndexes(in frame: CGRect) -> IndexSet {
        onVisibleBoundsChanged(size, frame)
        return content.visibleIndexes(in: frame)
    }
}
