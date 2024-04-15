//  Created by y H on 2024/4/7.

import UIKit

public struct SwipeActionsComponent: Component {
    public let component: any Component
    
    @Environment(\.swipeConfig)
    public var config: SwipeConfig
    
    public var actions: [any SwipeAction]
    
    public init(component: any Component, @SwipeActionBuilder _ actionsBuilder: () -> [any SwipeAction]) {
        self.component = component
        self.actions = actionsBuilder()
    }
    
    public func layout(_ constraint: Constraint) -> some RenderNode {
        let renderNode = component.layout(constraint)
        return SwipeActionsRenderNode(size: renderNode.size.bound(to: constraint), component: component, content: renderNode, actions: actions, config: config)
    }
}

public struct SwipeActionsRenderNode: RenderNode {
    /// The size of the render node.
    public let size: CGSize

    /// The component that is being rendered by this node.
    public let component: any Component

    /// The rendered content of the component.
    public let content: any RenderNode
    
    public let actions: [any SwipeAction]
    
    public let config: SwipeConfig
    
    /// The identifier for the render node, if it has one.
    public var id: String? {
        content.id
    }
    
    public func updateView(_ view: SwipeView) {
        view.config = config
        view.actions = actions
        view.contentView.engine.reloadWithExisting(component: component, renderNode: content)
    }
}

// MARK: - Environment

public struct SwipeConfigEnvironmentKey: EnvironmentKey {
    public static var defaultValue: SwipeConfig {
        get {
            SwipeConfig.default
        }
        set {
            SwipeConfig.default = newValue
        }
    }
}


public extension EnvironmentValues {
    /// The `SwipeConfig` instance for the current environment.
    var swipeConfig: SwipeConfig {
        get { self[SwipeConfigEnvironmentKey.self] }
        set { self[SwipeConfigEnvironmentKey.self] = newValue }
    }
}

/// An extension to allow `Component` to modify its environment's `SwipeConfig`.
@available(iOS 14.0, *)
public extension Component {
    /// Modifies the current `SwipeConfig` of the component's environment.
    ///
    /// - Parameter SwipeConfig: The `SwipeConfig` to set in the environment.
    /// - Returns: An `EnvironmentComponent` configured with the new `PrimaryMenuConfig`.
    func swipeConfig(_ swipeConfig: SwipeConfig) -> EnvironmentComponent<SwipeConfig, Self> {
        environment(\.swipeConfig, value: swipeConfig)
    }
}


public extension Component {
    func swipeActions(@SwipeActionBuilder _ actionsBuilder: () -> [any SwipeAction]) -> SwipeActionsComponent {
        SwipeActionsComponent(component: self, actionsBuilder)
    }
}
