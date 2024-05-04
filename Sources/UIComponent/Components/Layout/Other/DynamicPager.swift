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
    /// The total number of pages in the pager.
    public let count: Int
    /// The content provider that returns a component for a given page index.
    public let content: (Int) -> any Component
    /// The width of each page in the pager. nil to match the parent container width.
    public let pageWidth: CGFloat?

    /// Initializes a new `DynamicHPager` with the specified number of pages and content provider.
    /// - Parameters:
    ///   - count: The total number of pages.
    ///   - pageWidth: The width of each page in the pager. `nil` to match the parent container width. default to `nil`.
    ///   - content: A closure that provides the content for a given page index.
    public init(count: Int, pageWidth: CGFloat? = nil, content: @escaping (Int) -> any Component) {
        self.count = count
        self.pageWidth = pageWidth
        self.content = content
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        DynamicHPagerRenderNode(count: count,
                                pageSize: CGSize(width: pageWidth ?? constraint.maxSize.width, height: constraint.maxSize.height),
                                content: content)
    }
}

public struct DynamicHPagerRenderNode: RenderNode {
    public typealias View = UIView

    public let count: Int
    public let pageSize: CGSize
    public let content: (Int) -> any Component

    public var size: CGSize {
        CGSize(width: pageSize.width * CGFloat(count), height: pageSize.height)
    }

    public func visibleChildren(in frame: CGRect) -> [RenderNodeChild] {
        let start = Int(frame.minX / pageSize.width)
        let end = Int((frame.maxX - 0.1) / pageSize.width)
        let indexes = start...end
        return indexes.map { i in
            RenderNodeChild(renderNode: content(i).layout(Constraint(tightSize: pageSize)),
                            position: CGPoint(x: CGFloat(i) * pageSize.width, y: 0),
                            index: i)
        }
    }
}

/// A component that lays out its children vertically in a paging fashion similar to an ``VPager``.
/// However, instead of creating the child components all at once, it creates them on demand when it needs to render the specific page.
public struct DynamicVPager: Component {
    /// The total number of pages in the pager.
    public let count: Int
    /// The content provider that returns a component for a given page index.
    public let content: (Int) -> any Component
    /// The height of each page in the pager. nil to match the parent container height.
    public let pageHeight: CGFloat?

    /// Initializes a new `DynamicVPager` with the specified number of pages and content provider.
    /// - Parameters:
    ///   - count: The total number of pages.
    ///   - pageHeight: The height of each page in the pager. `nil` to match the parent container height. default to `nil`.
    ///   - content: A closure that provides the content for a given page index.
    public init(count: Int, pageHeight: CGFloat? = nil, content: @escaping (Int) -> any Component) {
        self.count = count
        self.pageHeight = pageHeight
        self.content = content
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        DynamicVPagerRenderNode(count: count,
                                pageSize: CGSize(width: constraint.maxSize.width, height: pageHeight ?? constraint.maxSize.height),
                                content: content)
    }
}

public struct DynamicVPagerRenderNode: RenderNode {
    public typealias View = UIView

    public let count: Int
    public let pageSize: CGSize
    public let content: (Int) -> any Component

    public var size: CGSize {
        CGSize(width: pageSize.width, height: pageSize.height * CGFloat(count))
    }

    public func visibleChildren(in frame: CGRect) -> [RenderNodeChild] {
        let start = Int(frame.minY / pageSize.height)
        let end = Int((frame.maxY - 0.1) / pageSize.height)
        let indexes = start...end
        return indexes.map { i in
            RenderNodeChild(renderNode: content(i).layout(Constraint(tightSize: pageSize)),
                            position: CGPoint(x: 0, y: CGFloat(i) * pageSize.height),
                            index: i)
        }
    }
}
