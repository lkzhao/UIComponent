//  Created by Luke Zhao on 8/23/20.

import UIKit

/// # ComponentViewComponent
///
/// Wraps a `component` inside a `ComponentDisplayableView`.
///
/// This is used to power the `.view()` and `.scrollView()` modifiers.
public struct ComponentViewComponent<View: ComponentDisplayableView>: ViewComponent {
    let component: Component
    public init(component: Component) {
        self.component = component
    }
    public func layout(_ constraint: Constraint) -> ComponentRenderNode<View> {
        let renderNode = component.layout(constraint)
        return ComponentRenderNode(size: renderNode.size.bound(to: constraint), component: component, renderNode: renderNode)
    }
}

/// RenderNode for the `ComponentViewComponent`
public struct ComponentRenderNode<View: ComponentDisplayableView>: RenderNode {
    public let size: CGSize
    public let component: Component
    public let renderNode: any RenderNode

    private var viewRenderNode: (any RenderNode)? {
        renderNode as? (any RenderNode)
    }
    public var id: String? {
        viewRenderNode?.id
    }
    public var animator: Animator? {
        viewRenderNode?.animator
    }
    public var keyPath: String {
        "\(type(of: self))." + (viewRenderNode?.keyPath ?? "\(type(of: renderNode))")
    }
    public func updateView(_ view: View) {
        view.engine.reloadWithExisting(component: component, renderNode: renderNode)
    }
}
