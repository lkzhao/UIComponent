//  Created by Luke Zhao on 8/22/20.

import Foundation

@resultBuilder
public struct ComponentArrayBuilder {
    public static func buildExpression(_ expression: ComponentArrayContainer) -> [any Component] {
        expression.components
    }
    public static func buildExpression(_ expression: any Component) -> [any Component] {
        [expression]
    }
    public static func buildExpression(_ expression: [any Component]) -> [any Component] {
        expression
    }
    public static func buildBlock(_ segments: [any Component]...) -> [any Component] {
        segments.flatMap { $0 }
    }
    public static func buildIf(_ segments: [any Component]?...) -> [any Component] {
        segments.flatMap { $0 ?? [] }
    }
    public static func buildEither(first: [any Component]) -> [any Component] {
        first
    }
    public static func buildEither(second: [any Component]) -> [any Component] {
        second
    }
    public static func buildArray(_ components: [[any Component]]) -> [any Component] {
        components.flatMap { $0 }
    }
    public static func buildLimitedAvailability(_ component: [any Component]) -> [any Component] {
        component
    }
}

public protocol ComponentArrayContainer {
    var components: [any Component] { get }
}
