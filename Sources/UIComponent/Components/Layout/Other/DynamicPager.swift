//
//  File.swift
//  
//
//  Created by Luke Zhao on 2/20/24.
//

import UIKit

/// A component that lays out its children horizontally in a paging fashion similar to an ``HPager``.
/// However, instead of creating the child components all at once, it creates them on demand when it needs to render the specific page.
public struct DynamicHPager: Component {
    /// The total number of pages.
    public let count: Int
    /// Defines how child components are aligned along the cross axis.
    public let alignItems: CrossAxisAlignment
    /// The content provider that returns a component for a given page index.
    public let content: (Int) -> any Component

    /// Initializes a new `DynamicHPager` with the specified number of pages and content provider.
    /// - Parameters:
    ///   - count: The total number of pages.
    ///   - alignItems: Defines how child components are aligned along the cross axis.
    ///   - content: A closure that provides the content for a given page index.
    public init(count: Int, alignItems: CrossAxisAlignment = .start, content: @escaping (Int) -> any Component) {
        self.count = count
        self.alignItems = alignItems
        self.content = content
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        DynamicHStackRenderNode(count: count,
                                constraintSize: constraint.maxSize,
                                spacing: 0,
                                alignItems: alignItems,
                                content: content)
    }
}

/// A component that lays out its children vertically in a paging fashion similar to an ``VPager``.
/// However, instead of creating the child components all at once, it creates them on demand when it needs to render the specific page.
public struct DynamicVPager: Component {
    /// The total number of pages.
    public let count: Int
    /// Defines how child components are aligned along the cross axis.
    public let alignItems: CrossAxisAlignment
    /// The content provider that returns a component for a given page index.
    public let content: (Int) -> any Component

    /// Initializes a new `DynamicVPager` with the specified number of pages and content provider.
    /// - Parameters:
    ///   - count: The total number of pages.
    ///   - alignItems: Defines how child components are aligned along the cross axis.
    ///   - content: A closure that provides the content for a given page index.
    public init(count: Int, alignItems: CrossAxisAlignment = .start, content: @escaping (Int) -> any Component) {
        self.count = count
        self.alignItems = alignItems
        self.content = content
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        DynamicVStackRenderNode(count: count,
                                constraintSize: constraint.maxSize,
                                spacing: 0,
                                alignItems: alignItems,
                                content: content)
    }
}
