//  Created by Luke Zhao on 8/22/20.

import UIKit

/// An enumeration to define the main axis alignment of a layout.
public enum MainAxisAlignment: CaseIterable {
    case start, end, center, spaceBetween, spaceAround, spaceEvenly
}

/// An enumeration to define the cross axis alignment of a layout.
public enum CrossAxisAlignment: CaseIterable {
    case start, end, center, stretch, baselineFirst, baselineLast
}

/// Protocol defining the base layout behavior.
/// It should be used with either the `VerticalLayoutProtocol` or `HorizontalLayoutProtocol` to provide a concrete implementation of the methods.
public protocol BaseLayoutProtocol {
    associatedtype R: RenderNode
    /// Retrieves the main axis value from a `CGPoint`.
    @inline(__always) func main(_ size: CGPoint) -> CGFloat
    /// Retrieves the cross axis value from a `CGPoint`.
    @inline(__always) func cross(_ size: CGPoint) -> CGFloat
    /// Retrieves the main axis value from a `CGSize`.
    @inline(__always) func main(_ size: CGSize) -> CGFloat
    /// Retrieves the cross axis value from a `CGSize`.
    @inline(__always) func cross(_ size: CGSize) -> CGFloat
    /// Creates a `CGSize` given main and cross axis values.
    @inline(__always) func size(main: CGFloat, cross: CGFloat) -> CGSize
    /// Creates a `CGPoint` given main and cross axis values.
    @inline(__always) func point(main: CGFloat, cross: CGFloat) -> CGPoint
    /// Generates a render node for the layout.
    @inline(__always) func renderNode(size: CGSize, children: [any RenderNode], positions: [CGPoint]) -> R
}

/// Protocol for layouts that align children vertically.
public protocol VerticalLayoutProtocol: BaseLayoutProtocol {}

/// Protocol for layouts that align children horizontally.
public protocol HorizontalLayoutProtocol: BaseLayoutProtocol {}

extension VerticalLayoutProtocol {
    @inline(__always) public func main(_ point: CGPoint) -> CGFloat {
        point.y
    }
    @inline(__always) public func cross(_ point: CGPoint) -> CGFloat {
        point.x
    }
    @inline(__always) public func main(_ size: CGSize) -> CGFloat {
        size.height
    }
    @inline(__always) public func cross(_ size: CGSize) -> CGFloat {
        size.width
    }
    @inline(__always) public func size(main: CGFloat, cross: CGFloat) -> CGSize {
        CGSize(width: cross, height: main)
    }
    @inline(__always) public func point(main: CGFloat, cross: CGFloat) -> CGPoint {
        CGPoint(x: cross, y: main)
    }
    @inline(__always) public func renderNode(size: CGSize, children: [any RenderNode], positions: [CGPoint]) -> VerticalRenderNode {
        let max = main(children.max { main($0.size) < main($1.size) }?.size ?? .zero)
        return VerticalRenderNode(size: size, children: children, positions: positions, mainAxisMaxValue: max)
    }
}

extension HorizontalLayoutProtocol {
    @inline(__always) public func main(_ point: CGPoint) -> CGFloat {
        point.x
    }
    @inline(__always) public func cross(_ point: CGPoint) -> CGFloat {
        point.y
    }
    @inline(__always) public func main(_ size: CGSize) -> CGFloat {
        size.width
    }
    @inline(__always) public func cross(_ size: CGSize) -> CGFloat {
        size.height
    }
    @inline(__always) public func size(main: CGFloat, cross: CGFloat) -> CGSize {
        CGSize(width: main, height: cross)
    }
    @inline(__always) public func point(main: CGFloat, cross: CGFloat) -> CGPoint {
        CGPoint(x: main, y: cross)
    }
    @inline(__always) public func renderNode(size: CGSize, children: [any RenderNode], positions: [CGPoint]) -> HorizontalRenderNode {
        let max = main(children.max { main($0.size) < main($1.size) }?.size ?? .zero)
        return HorizontalRenderNode(size: size, children: children, positions: positions, mainAxisMaxValue: max)
    }
}

struct LayoutHelper {
    static func distribute(
        justifyContent: MainAxisAlignment,
        maxPrimary: CGFloat,
        totalPrimary: CGFloat,
        minimunSpacing: CGFloat,
        numberOfItems: Int
    ) -> (offset: CGFloat, spacing: CGFloat) {
        var offset: CGFloat = 0
        var spacing = minimunSpacing
        guard numberOfItems > 0 else { return (offset, spacing) }
        if maxPrimary != .infinity,
            totalPrimary + CGFloat(numberOfItems - 1) * minimunSpacing < maxPrimary
        {
            let leftOverPrimary = maxPrimary - totalPrimary
            switch justifyContent {
            case .start:
                break
            case .center:
                offset += (leftOverPrimary - minimunSpacing * CGFloat(numberOfItems - 1)) / 2
            case .end:
                offset += (leftOverPrimary - minimunSpacing * CGFloat(numberOfItems - 1))
            case .spaceBetween:
                guard numberOfItems > 1 else { break }
                spacing = leftOverPrimary / CGFloat(numberOfItems - 1)
            case .spaceAround:
                spacing = leftOverPrimary / CGFloat(numberOfItems)
                offset = spacing / 2
            case .spaceEvenly:
                spacing = leftOverPrimary / CGFloat(numberOfItems + 1)
                offset = spacing
            }
        }
        return (offset, spacing)
    }
}
