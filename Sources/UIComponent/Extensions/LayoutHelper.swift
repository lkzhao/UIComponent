//  Created by Luke Zhao on 8/22/20.

import UIKit

public enum MainAxisAlignment: CaseIterable {
    case start, end, center, spaceBetween, spaceAround, spaceEvenly
}

public enum CrossAxisAlignment: CaseIterable {
    case start, end, center, stretch
}

public protocol BaseLayoutProtocol {
    @inline(__always) func main(_ size: CGPoint) -> CGFloat
    @inline(__always) func cross(_ size: CGPoint) -> CGFloat
    @inline(__always) func main(_ size: CGSize) -> CGFloat
    @inline(__always) func cross(_ size: CGSize) -> CGFloat
    @inline(__always) func size(main: CGFloat, cross: CGFloat) -> CGSize
    @inline(__always) func point(main: CGFloat, cross: CGFloat) -> CGPoint
    @inline(__always) func renderNode(size: CGSize, children: [RenderNode], positions: [CGPoint]) -> RenderNode
}

public protocol VerticalLayoutProtocol: BaseLayoutProtocol {}

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
    @inline(__always) public func renderNode(size: CGSize, children: [RenderNode], positions: [CGPoint]) -> RenderNode {
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
    @inline(__always) public func renderNode(size: CGSize, children: [RenderNode], positions: [CGPoint]) -> RenderNode {
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
