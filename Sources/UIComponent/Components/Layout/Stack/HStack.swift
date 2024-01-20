//  Created by Luke Zhao on 8/6/21.

import UIKit

/// A horizontal stack component that lays out its children in a horizontal line.
public struct HStack: Component, Stack, HorizontalLayoutProtocol {
    /// The spacing between each child component.
    public let spacing: CGFloat
    /// The alignment of children along the main axis.
    public let justifyContent: MainAxisAlignment
    /// The alignment of children along the cross axis.
    public let alignItems: CrossAxisAlignment
    /// The child components to be laid out.
    public let children: [any Component]
    
    /// Initializes a new horizontal stack with the given properties.
    /// - Parameters:
    ///   - spacing: The spacing between each child component.
    ///   - justifyContent: The alignment of children along the main axis.
    ///   - alignItems: The alignment of children along the cross axis.
    ///   - children: The child components to be laid out.
    public init(
        spacing: CGFloat = 0,
        justifyContent: MainAxisAlignment = .start,
        alignItems: CrossAxisAlignment = .start,
        children: [any Component] = []
    ) {
        self.spacing = spacing
        self.justifyContent = justifyContent
        self.alignItems = alignItems
        self.children = children
    }
}

extension HStack {
    /// Initializes a new ``HStack`` with the given properties using a ``ComponentArrayBuilder`` closure.
    /// - Parameters:
    ///   - spacing: The spacing between each child component.
    ///   - justifyContent: The alignment of children along the main axis.
    ///   - alignItems: The alignment of children along the cross axis.
    ///   - content: A result builder closure that returns the child components to be laid out.
    public init(spacing: CGFloat = 0, justifyContent: MainAxisAlignment = .start, alignItems: CrossAxisAlignment = .start, @ComponentArrayBuilder _ content: () -> [any Component]) {
        self.init(
            spacing: spacing,
            justifyContent: justifyContent,
            alignItems: alignItems,
            children: content()
        )
    }
}
