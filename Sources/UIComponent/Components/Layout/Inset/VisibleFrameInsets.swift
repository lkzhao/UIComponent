//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct VisibleFrameInsets<Content: Component>: Component {
    let child: Content
    let insets: UIEdgeInsets

    public init(child: Content, insets: UIEdgeInsets) {
        self.child = child
        self.insets = insets
    }

    public func layout(_ constraint: Constraint) -> VisibleFrameInsetRenderNode<Content.R> {
        VisibleFrameInsetRenderNode(content: child.layout(constraint), insets: insets)
    }
}

public struct DynamicVisibleFrameInset<Content: Component>: Component {
    let child: Content
    let insetProvider: (CGRect) -> UIEdgeInsets

    public init(child: Content, insetProvider: @escaping (CGRect) -> UIEdgeInsets) {
        self.child = child
        self.insetProvider = insetProvider
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        DynamicVisibleFrameInsetRenderNode(content: child.layout(constraint), insetProvider: insetProvider)
    }
}

public struct VisibleFrameInsetRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let insets: UIEdgeInsets

    public func visibleIndexes(in frame: CGRect) -> IndexSet {
        content.visibleIndexes(in: frame.inset(by: insets))
    }

    public func visibleRenderables(in frame: CGRect) -> [Renderable] {
        content.visibleRenderables(in: frame.inset(by: insets))
    }
}

public struct DynamicVisibleFrameInsetRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let insetProvider: (CGRect) -> UIEdgeInsets

    public func visibleIndexes(in frame: CGRect) -> IndexSet {
        content.visibleIndexes(in: frame.inset(by: insetProvider(frame)))
    }

    public func visibleRenderables(in frame: CGRect) -> [Renderable] {
        content.visibleRenderables(in: frame.inset(by: insetProvider(frame)))
    }
}
