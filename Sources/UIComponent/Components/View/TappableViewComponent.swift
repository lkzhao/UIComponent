//
//  File.swift
//  
//
//  Created by Luke Zhao on 1/18/24.
//

import Foundation

/// A component that renders a ``TappableView``
public struct TappableViewComponent: Component {
    /// The configuration for the tappable view, obtained from the environment.
    @Environment(\.tappableViewConfig)
    public var config: TappableViewConfig
    
    /// The underlying component that this `TappableViewComponent` is wrapping.
    public let component: any Component
    
    /// The closure to be called when the tappable view is tapped.
    public let onTap: ((TappableView) -> Void)?

    /// Initializes a new `TappableViewComponent` with the given component and optional tap handler.
    /// - Parameters:
    ///   - component: The component to be made tappable.
    ///   - onTap: An optional closure that is called when the tappable view is tapped.
    public init(component: any Component, onTap: ((TappableView) -> Void)? = nil) {
        self.component = component
        self.onTap = onTap
    }

    /// Lays out the component within the given constraints and returns a `TappableViewRenderNode`.
    /// - Parameter constraint: The constraints to use when laying out the component.
    /// - Returns: A `TappableViewRenderNode` representing the laid out component.
    public func layout(_ constraint: Constraint) -> TappableViewRenderNode {
        let renderNode = component.layout(constraint)
        return TappableViewRenderNode(size: renderNode.size.bound(to: constraint), component: component, content: renderNode, onTap: onTap, config: config)
    }
}

/// A render node that represents a tappable view within the UI.
public struct TappableViewRenderNode: RenderNode {
    /// The size of the render node.
    public let size: CGSize
    
    /// The component that is being rendered by this node.
    public let component: any Component
    
    /// The rendered content of the component.
    public let content: any RenderNode
    
    /// The closure to be called when the tappable view is tapped.
    public let onTap: ((TappableView) -> Void)?
    
    /// The configuration for the tappable view.
    public let config: TappableViewConfig?

    /// The identifier for the render node, if it has one.
    public var id: String? {
        content.id
    }
    
    /// Updates the given `TappableView` with the current configuration and tap handler.
    /// - Parameter view: The `TappableView` to update.
    public func updateView(_ view: TappableView) {
        view.config = config
        view.onTap = onTap
        view.engine.reloadWithExisting(component: component, renderNode: content)
    }
}

// MARK: - Environment

/// The key for accessing `TappableViewConfig` values within the environment.
public struct TappableViewConfigEnvironmentKey: EnvironmentKey {
    public static var defaultValue: TappableViewConfig {
        get {
            TappableViewConfig.default
        }
        set {
            TappableViewConfig.default = newValue
        }
    }
}

/// An extension to provide easy access and modification of `TappableViewConfig` within `EnvironmentValues`.
public extension EnvironmentValues {
    /// The `TappableViewConfig` instance for the current environment.
    var tappableViewConfig: TappableViewConfig {
        get { self[TappableViewConfigEnvironmentKey.self] }
        set { self[TappableViewConfigEnvironmentKey.self] = newValue }
    }
}

/// An extension to allow `Component` to modify its environment's `TappableViewConfig`.
public extension Component {
    /// Modifies the current `TappableViewConfig` of the component's environment.
    ///
    /// - Parameter tappableViewConfig: The `TappableViewConfig` to set in the environment.
    /// - Returns: An `EnvironmentComponent` configured with the new `TappableViewConfig`.
    func tappableViewConfig(_ tappableViewConfig: TappableViewConfig) -> EnvironmentComponent<TappableViewConfig, Self> {
        environment(\.tappableViewConfig, value: tappableViewConfig)
    }
}
