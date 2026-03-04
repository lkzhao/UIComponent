//  Created by Luke Zhao on 3/3/26.

/// A component that reads its measured view size from cache and updates it after render.
public struct MeasureSizeComponent<Content: Component>: Component {
    @Environment(\.hostingView) private var hostingView

    /// The cache key used to store and retrieve measured size values.
    public let key: String
    /// The wrapped content component.
    public let content: Content

    /// Creates a measurement component for the provided content.
    /// - Parameters:
    ///   - key: The cache key for this measured view.
    ///   - content: The wrapped component.
    public init(key: String, content: Content) {
        self.key = key
        self.content = content
    }

    public func layout(_ constraint: Constraint) -> MeasureSizeRenderNode<Content.R> {
        let child = content.layout(constraint)
        let cachedSize = hostingView?.componentEngine.measuredSizes[key]?.bound(to: constraint)
        return MeasureSizeRenderNode(
            size: cachedSize ?? child.size,
            content: child,
            key: key,
            constraint: constraint,
            hostingView: hostingView
        )
    }
}

/// A render node wrapper that updates measured size cache after the backing view is available.
public struct MeasureSizeRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let size: CGSize
    public let content: Content
    let key: String
    let constraint: Constraint
    weak var hostingView: UIView?

    public func updateView(_ view: Content.View) {
        content.updateView(view)
        let measuredSize = view.sizeThatFits(constraint.maxSize).bound(to: constraint)
        if measuredSize != size, let hostingView {
            hostingView.componentEngine.measuredSizes[key] = measuredSize
            hostingView.componentEngine.setNeedsReload()
        }
    }
}
