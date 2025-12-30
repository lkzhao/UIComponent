//  Created by Luke Zhao on 12/30/25.

#if os(macOS)
import AppKit

/// Wraps a component inside an `NSScrollView`.
public struct MacScrollViewWrapperComponent: Component {
    public let component: any Component

    public init(component: any Component) {
        self.component = component
    }

    public func layout(_ constraint: Constraint) -> MacScrollViewWrapperRenderNode {
        let renderNode = component.layout(constraint)
        return MacScrollViewWrapperRenderNode(
            size: renderNode.size.bound(to: constraint),
            component: component,
            content: renderNode
        )
    }
}

public struct MacScrollViewWrapperRenderNode: RenderNode {
    public typealias View = NSScrollView

    public let size: CGSize
    public let component: any Component
    public let content: any RenderNode

    public func updateView(_ view: NSScrollView) {
        view.hasVerticalScroller = true
        view.drawsBackground = false

        let docView: NSView
        if let existing = view.documentView {
            docView = existing
        } else {
            let created = NSView(frame: .zero)
            created.wantsLayer = true
            view.documentView = created
            docView = created
        }

        docView.frame = CGRect(origin: .zero, size: content.size)
        docView.componentEngine.reloadWithExisting(component: component, renderNode: content)
    }

    public func contextValue(_ key: RenderNodeContextKey) -> Any? {
        content.contextValue(key)
    }
}
#endif

