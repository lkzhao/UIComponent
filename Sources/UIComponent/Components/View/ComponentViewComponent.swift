//  Created by Luke Zhao on 8/23/20.

import UIKit

/// # ComponentViewComponent
///
/// Wraps a `component` inside a `ComponentDisplayableView`.
///
/// This is used to power the `.view()` and `.scrollView()` modifiers.
public struct ComponentViewComponent<View: ComponentDisplayableView>: Component {
    let component: any Component
    public init(component: any Component) {
        self.component = component
    }
    public func layout(_ constraint: Constraint) -> ComponentViewRenderNode<View> {
        let renderNode = component.layout(constraint)
        return ComponentViewRenderNode(size: renderNode.size.bound(to: constraint), component: component, content: renderNode)
    }
}

/// RenderNode for the `ComponentViewComponent`
public struct ComponentViewRenderNode<View: ComponentDisplayableView>: RenderNode {
    public let size: CGSize
    public let component: any Component
    public let content: any RenderNode

    public var id: String? {
        content.id
    }
    public func updateView(_ view: View) {
        view.engine.reloadWithExisting(component: component, renderNode: content)
    }
}
