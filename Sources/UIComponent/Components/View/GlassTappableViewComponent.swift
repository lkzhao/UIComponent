//  Created by Luke Zhao on 5/6/26.

/// A component that renders a ``GlassTappableView``.
public struct GlassTappableViewComponent: Component {
    /// The configuration for the tappable view, obtained from the environment.
    @Environment(\.glassTappableViewConfig)
    public var config: GlassTappableViewConfig

    /// The underlying component that this `GlassTappableViewComponent` is wrapping.
    public let component: any Component

    /// The tint of the glass; nil for clear glass. See ``GlassTappableView/glassTintColor``.
    public let tintColor: UIColor?

    /// The closure to be called when the tappable view is tapped.
    public let onTap: ((GlassTappableView) -> Void)?

    /// Initializes a new `GlassTappableViewComponent` with the given component and optional tap handler.
    /// - Parameters:
    ///   - component: The component to be made tappable.
    ///   - tintColor: The tint of the glass; nil for clear glass.
    ///   - onTap: An optional closure that is called when the tappable view is tapped.
    public init(component: any Component, tintColor: UIColor? = nil, onTap: ((GlassTappableView) -> Void)? = nil) {
        self.component = component
        self.tintColor = tintColor
        self.onTap = onTap
    }

    /// Lays out the component within the given constraints and returns a `GlassTappableViewRenderNode`.
    /// - Parameter constraint: The constraints to use when laying out the component.
    /// - Returns: A `GlassTappableViewRenderNode` representing the laid out component.
    public func layout(_ constraint: Constraint) -> GlassTappableViewRenderNode {
        let renderNode = component.layout(constraint)
        return GlassTappableViewRenderNode(
            size: renderNode.size.bound(to: constraint),
            component: component,
            content: renderNode,
            tintColor: tintColor,
            onTap: onTap,
            config: config
        )
    }
}

/// A render node that represents a glass tappable view within the UI.
public struct GlassTappableViewRenderNode: RenderNode {
    /// The size of the render node.
    public let size: CGSize

    /// The component that is being rendered by this node.
    public let component: any Component

    /// The rendered content of the component.
    public let content: any RenderNode

    /// The tint of the glass; nil for clear glass.
    public let tintColor: UIColor?

    /// The closure to be called when the tappable view is tapped.
    public let onTap: ((GlassTappableView) -> Void)?

    /// The configuration for the tappable view.
    public let config: GlassTappableViewConfig?

    /// Updates the given `GlassTappableView` with the current tint, configuration, and tap handler.
    /// The glass is rebuilt only when its tint changes or its effect was replaced from outside.
    /// - Parameter view: The `GlassTappableView` to update.
    public func updateView(_ view: GlassTappableView) {
        view.glassTintColor = tintColor
        view.restoreDefaultEffectIfNeeded()
        view.config = config
        view.onTap = onTap
        view.contentView.componentEngine.reloadWithExisting(component: component, renderNode: content)
    }

    public func contextValue(_ key: RenderNodeContextKey) -> Any? {
        content.contextValue(key)
    }
}

// MARK: - Environment

/// The key for accessing `GlassTappableViewConfig` values within the environment.
public struct GlassTappableViewConfigEnvironmentKey: EnvironmentKey {
    public static var defaultValue: GlassTappableViewConfig {
        get {
            GlassTappableViewConfig.default
        }
        set {
            GlassTappableViewConfig.default = newValue
        }
    }
}

/// An extension to provide easy access and modification of `GlassTappableViewConfig` within `EnvironmentValues`.
public extension EnvironmentValues {
    /// The `GlassTappableViewConfig` instance for the current environment.
    var glassTappableViewConfig: GlassTappableViewConfig {
        get { self[GlassTappableViewConfigEnvironmentKey.self] }
        set { self[GlassTappableViewConfigEnvironmentKey.self] = newValue }
    }
}

/// An extension to allow `Component` to modify its environment's `GlassTappableViewConfig`.
public extension Component {
    /// Modifies the current `GlassTappableViewConfig` of the component's environment.
    ///
    /// - Parameter glassTappableViewConfig: The `GlassTappableViewConfig` to set in the environment.
    /// - Returns: An `EnvironmentComponent` configured with the new `GlassTappableViewConfig`.
    func glassTappableViewConfig(_ glassTappableViewConfig: GlassTappableViewConfig) -> EnvironmentComponent<GlassTappableViewConfig, Self> {
        environment(\.glassTappableViewConfig, value: glassTappableViewConfig)
    }
}
