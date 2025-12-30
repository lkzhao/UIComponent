//  Created by Luke Zhao on 10/10/22.

/// A component that observes the visible bounds of its content.
public struct VisibleBoundsObserverComponent<Content: Component>: Component {
    /// The child component that it will observe.
    public let content: Content
    /// The closure that gets called when the visible bounds of the content component changes.
    /// - Parameters:
    ///   - size: The new size of the content component
    ///   - rect: The new rectangle of the visible bounds in the component coordinate space.
    public let onVisibleBoundsChanged: (CGSize, CGRect) -> ()

    /// Initializes a new `VisibleBoundsObserverComponent` with the given content and a closure to call when the visible bounds change.
    /// - Parameters:
    ///   - content: The content component to observe.
    ///   - onVisibleBoundsChanged: A closure that is called with the new size and visible rectangle when the visible bounds change.
    public init(content: Content, onVisibleBoundsChanged: @escaping (CGSize, CGRect) -> Void) {
        self.content = content
        self.onVisibleBoundsChanged = onVisibleBoundsChanged
    }

    public func layout(_ constraint: Constraint) -> VisibleBoundsObserverRenderNode<Content.R> {
        VisibleBoundsObserverRenderNode(content: content.layout(constraint), onVisibleBoundsChanged: onVisibleBoundsChanged)
    }
}

/// A render node that wraps another render node and observes the visible bounds of its content.
public struct VisibleBoundsObserverRenderNode<Content: RenderNode>: RenderNodeWrapper {
    /// The child component that it will observe.
    public let content: Content
    /// The closure that gets called when the visible bounds of the content component changes.
    /// - Parameters:
    ///   - size: The size of the content render node.
    ///   - rect: The new visible bounds.
    public let onVisibleBoundsChanged: (CGSize, CGRect) -> ()

    /// Initializes a new instance of `VisibleBoundsObserverRenderNode`.
    /// - Parameters:
    ///   - content: The content render node to observe.
    ///   - onVisibleBoundsChanged: A closure that is called with the new size and visible rectangle when the visible bounds change.
    public init(content: Content, onVisibleBoundsChanged: @escaping (CGSize, CGRect) -> Void) {
        self.content = content
        self.onVisibleBoundsChanged = onVisibleBoundsChanged
    }

    public func visibleChildren(in frame: CGRect) -> [RenderNodeChild] {
        onVisibleBoundsChanged(size, frame)
        return content.visibleChildren(in: frame)
    }
}
