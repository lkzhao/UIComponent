//  Created by Luke Zhao on 8/6/21.

import UIKit

/// A vertical stack component that arranges its children in a vertical line.
public struct VStack: Component, Stack, VerticalLayoutProtocol {
    /// The spacing between each component in the stack.
    public let spacing: CGFloat
    /// The alignment of components along the main axis.
    public let justifyContent: MainAxisAlignment
    /// The alignment of components along the cross axis.
    public let alignItems: CrossAxisAlignment
    /// The array of components that VStack holds.
    public let children: [any Component]
    
    /// Initializes a new VStack with the provided parameters.
    /// - Parameters:
    ///   - spacing: The space between adjacent components, defaults to 0.
    ///   - justifyContent: The main axis alignment of the components, defaults to .start.
    ///   - alignItems: The cross axis alignment of the components, defaults to .start.
    ///   - children: The components to be laid out, defaults to an empty array.
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

extension VStack {
    /// Initializes a new ``VStack`` with the given properties using a ``ComponentArrayBuilder`` closure.
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
