//
//  File.swift
//  
//
//  Created by Luke Zhao on 1/19/24.
//

import UIKit

/// A component that renders a ``PrimaryMenu``
@available(iOS 14.0, *)
public struct PrimaryMenuComponent: Component {
    /// The configuration for the primary menu view, obtained from the environment.
    @Environment(\.primaryMenuConfig)
    public var config: PrimaryMenuConfig

    /// The underlying component that this `PrimaryMenuComponent` is wrapping.
    public let component: any Component

    /// The menu to be displayed as part of the primary menu component.
    public let menu: UIMenu

    public init(component: any Component, menu: UIMenu) {
        self.component = component
        self.menu = menu
    }

    /// Lays out the component within the given constraints and returns a `PrimaryMenuRenderNode`.
    /// - Parameter constraint: The constraints to use when laying out the component.
    /// - Returns: A `PrimaryMenuRenderNode` representing the laid out component.
    public func layout(_ constraint: Constraint) -> PrimaryMenuRenderNode {
        let renderNode = component.layout(constraint)
        return PrimaryMenuRenderNode(size: renderNode.size.bound(to: constraint), component: component, content: renderNode, menu: menu, config: config)
    }
}

/// A render node that renders a ``PrimaryMenu``.
@available(iOS 14.0, *)
public struct PrimaryMenuRenderNode: RenderNode {
    /// The size of the render node.
    public let size: CGSize

    /// The component that is being rendered by this node.
    public let component: any Component

    /// The rendered content of the component.
    public let content: any RenderNode

    /// The menu to be displayed as part of the primary menu component.
    public let menu: UIMenu?

    /// The configuration for the tappable view.
    public let config: PrimaryMenuConfig?

    /// The identifier for the render node, if it has one.
    public var id: String? {
        content.id
    }

    /// Updates the given `PrimaryMenu` with the current configuration and tap handler.
    /// - Parameter view: The `PrimaryMenu` to update.
    public func updateView(_ view: PrimaryMenu) {
        view.config = config
        view.menu = menu
        view.contentView.engine.reloadWithExisting(component: component, renderNode: content)
    }
}

// MARK: - Environment

/// The key for accessing `PrimaryMenuConfig` values within the environment.
@available(iOS 14.0, *)
public struct PrimaryMenuConfigEnvironmentKey: EnvironmentKey {
    public static var defaultValue: PrimaryMenuConfig {
        get {
            PrimaryMenuConfig.default
        }
        set {
            PrimaryMenuConfig.default = newValue
        }
    }
}

/// An extension to provide easy access and modification of `PrimaryMenuConfig` within `EnvironmentValues`.
@available(iOS 14.0, *)
public extension EnvironmentValues {
    /// The `PrimaryMenuConfig` instance for the current environment.
    var primaryMenuConfig: PrimaryMenuConfig {
        get { self[PrimaryMenuConfigEnvironmentKey.self] }
        set { self[PrimaryMenuConfigEnvironmentKey.self] = newValue }
    }
}

/// An extension to allow `Component` to modify its environment's `PrimaryMenuConfig`.
@available(iOS 14.0, *)
public extension Component {
    /// Modifies the current `PrimaryMenuConfig` of the component's environment.
    ///
    /// - Parameter primaryMenuConfig: The `PrimaryMenuConfig` to set in the environment.
    /// - Returns: An `EnvironmentComponent` configured with the new `PrimaryMenuConfig`.
    func primaryMenuConfig(_ primaryMenuConfig: PrimaryMenuConfig) -> EnvironmentComponent<PrimaryMenuConfig, Self> {
        environment(\.primaryMenuConfig, value: primaryMenuConfig)
    }
}
