//  Created by Luke Zhao on 8/22/20.


import UIKit

/// A base render node protocol for a stack that provide implementation for ``visibleChildren(in:)``
public protocol StackRenderNode: RenderNode, BaseLayoutProtocol {
    /// The size of the render node.
    var size: CGSize { get }
    /// The child render nodes.
    var children: [any RenderNode] { get }
    /// The positions of each child render node.
    var positions: [CGPoint] { get }
    /// The maximum value along the main axis.
    var mainAxisMaxValue: CGFloat { get }
}

extension StackRenderNode {
    public func visibleChildren(in frame: CGRect) -> [RenderNodeChild] {
        guard let start = firstVisibleIndex(in: frame) else { return [] }
        var index = start
        let endPoint = main(frame.origin) + main(frame.size)
        while index < positions.count, main(positions[index]) < endPoint {
            index += 1
        }
        return (start..<index).map {
            RenderNodeChild(renderNode: children[$0], position: positions[$0], index: $0)
        }
    }

    public func firstVisibleIndex(in frame: CGRect) -> Int? {
        let beginPoint = main(frame.origin) - mainAxisMaxValue
        let endPoint = main(frame.origin) + main(frame.size)
        var index = positions.binarySearch { main($0) < beginPoint }
        while index < positions.count, main(positions[index]) < endPoint {
            if main(positions[index]) + main(children[index].size) > main(frame.origin) {
                return index
            }
            index += 1
        }
        return nil
    }
}

/// A type of render node that is optimized for horizontal layout.
///
/// - Renders children when they are inside the visible frame.
/// - It uses binary search to check which children are visible.
/// - Children must be sorted by their x position value.
/// - Needs to provide a mainAxisMaxValue with the max width of the children.
public struct HorizontalRenderNode: StackRenderNode, HorizontalLayoutProtocol {
    public typealias View = UIView
    public let size: CGSize
    public let children: [any RenderNode]
    public let positions: [CGPoint]
    public let mainAxisMaxValue: CGFloat

    public var shouldRenderView: Bool {
        false
    }

    public init(size: CGSize, children: [any RenderNode], positions: [CGPoint], mainAxisMaxValue: CGFloat) {
        self.size = size
        self.children = children
        self.positions = positions
        self.mainAxisMaxValue = mainAxisMaxValue
    }
}

/// A type of render node that is optimized for vertical layout.
///
/// - Renders children when they are inside the visible frame.
/// - It uses binary search to check which children are visible.
/// - Children must be sorted by their y position value.
/// - Needs to provide a mainAxisMaxValue with the max height of the children.
public struct VerticalRenderNode: StackRenderNode, VerticalLayoutProtocol {
    public typealias View = UIView
    public let size: CGSize
    public let children: [any RenderNode]
    public let positions: [CGPoint]
    public let mainAxisMaxValue: CGFloat
    
    public var shouldRenderView: Bool {
        false
    }

    public init(size: CGSize, children: [any RenderNode], positions: [CGPoint], mainAxisMaxValue: CGFloat) {
        self.size = size
        self.children = children
        self.positions = positions
        self.mainAxisMaxValue = mainAxisMaxValue
    }
}

/// A type of render node for generic layout use
///
/// - Renders children when they are inside the visible frame.
/// - This could be slow because it needs to loop through all children to check whether they are inside the visible frame.
public struct SlowRenderNode: RenderNode {
    public typealias View = UIView
    public let size: CGSize
    public let children: [any RenderNode]
    public let positions: [CGPoint]
    
    public var shouldRenderView: Bool {
        false
    }

    public init(size: CGSize, children: [any RenderNode], positions: [CGPoint]) {
        self.size = size
        self.children = children
        self.positions = positions
    }

    public func visibleChildren(in frame: CGRect) -> [RenderNodeChild] {
        var result = [RenderNodeChild]()

        for (i, position) in positions.enumerated() {
            let child = children[i]
            let childFrame = CGRect(origin: position, size: child.size)
            if frame.intersects(childFrame) {
                let nodeChild = RenderNodeChild(renderNode: child, position: position, index: i)
                result.append(nodeChild)
            }
        }

        return result
    }
}

/// A type of render node for generic layout use
///
/// - Renders all childrens all the time.
/// - Not suitable for rendering a list of items.
public struct AlwaysRenderNode: RenderNode {
    public typealias View = UIView
    public let size: CGSize
    public let children: [any RenderNode]
    public let positions: [CGPoint]
    
    public var shouldRenderView: Bool {
        false
    }

    public init(size: CGSize, children: [any RenderNode], positions: [CGPoint]) {
        self.size = size
        self.children = children
        self.positions = positions
    }
}
