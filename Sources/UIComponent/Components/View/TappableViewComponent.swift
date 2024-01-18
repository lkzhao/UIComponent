//
//  File.swift
//  
//
//  Created by Luke Zhao on 1/18/24.
//

import Foundation

public struct TappableViewComponent: Component {
    @Environment(\.tappableViewConfig)
    public var config: TappableViewConfig
    public let component: any Component
    public let onTap: ((TappableView) -> Void)?

    public init(component: any Component, onTap: ((TappableView) -> Void)? = nil) {
        self.component = component
        self.onTap = onTap
    }

    public func layout(_ constraint: Constraint) -> TappableViewRenderNode {
        let renderNode = component.layout(constraint)
        return TappableViewRenderNode(size: renderNode.size.bound(to: constraint), component: component, content: renderNode, onTap: onTap, config: config)
    }
}

public struct TappableViewRenderNode: RenderNode {
    public let size: CGSize
    public let component: any Component
    public let content: any RenderNode
    public let onTap: ((TappableView) -> Void)?
    public let config: TappableViewConfig?

    public var id: String? {
        content.id
    }
    public func updateView(_ view: TappableView) {
        view.config = config
        view.onTap = onTap
        view.engine.reloadWithExisting(component: component, renderNode: content)
    }
}

// MARK: - Environment

public struct TappableViewConfigEnvironmentKey: EnvironmentKey {
    public static var defaultValue: TappableViewConfig = TappableViewConfig(onHighlightChanged: nil, didTap: nil)
}

public extension EnvironmentValues {
    var tappableViewConfig: TappableViewConfig {
        get { self[TappableViewConfigEnvironmentKey.self] }
        set { self[TappableViewConfigEnvironmentKey.self] = newValue }
    }
}

public extension Component {
    func tappableViewConfig(_ tappableViewConfig: TappableViewConfig) -> EnvironmentComponent<TappableViewConfig, Self> {
        environment(\.tappableViewConfig, value: tappableViewConfig)
    }
}
