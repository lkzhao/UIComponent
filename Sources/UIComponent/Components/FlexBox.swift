//
//  File.swift
//  
//
//  Created by y H on 2021/7/20.
//

import UIKit

public enum FlexDirection {
    case row, column
}

public enum FlexItemAlign {
    case start, end, center, stretch, auto
}

public struct FlexAlign: Component {
    public let flex: CGFloat
    public let align: FlexItemAlign
    public let child: Component
    public func layout(_ constraint: Constraint) -> Renderer {
        child.layout(constraint)
    }
}

public extension Component {
    func flexAlin(_ flex: CGFloat = 1, align: FlexItemAlign = .auto) -> FlexAlign {
        FlexAlign(flex: flex, align: align, child: self)
    }
}

public protocol FlexBox: Component, BaseLayoutProtocol {
    var direction: FlexDirection { get }
    var justifyContent: MainAxisAlignment { get }
    var alignItems: CrossAxisAlignment { get }
    var alignContent: MainAxisAlignment { get }
    var children: [Component] { get }
}

extension FlexBox {
    @inline(__always) public func main(_ point: CGPoint) -> CGFloat {
        direction == .row ? point.x : point.y
    }
    @inline(__always) public func cross(_ point: CGPoint) -> CGFloat {
        direction == .row ? point.y : point.x
    }
    @inline(__always) public func main(_ size: CGSize) -> CGFloat {
        direction == .row ? size.width : size.height
    }
    @inline(__always) public func cross(_ size: CGSize) -> CGFloat {
        direction == .row ? size.height : size.width
    }
    @inline(__always) public func size(main: CGFloat, cross: CGFloat) -> CGSize {
        CGSize(width: direction == .row ? main : cross, height: direction == .row ? cross : main)
    }
    @inline(__always) public func point(main: CGFloat, cross: CGFloat) -> CGPoint {
        CGPoint(x: direction == .row ? main : cross, y: direction == .row ? cross : main)
    }
    @inline(__always) public func renderer(size: CGSize, children: [Renderer], positions: [CGPoint]) -> Renderer {
        let max = main(children.max { main($0.size) < main($1.size) }?.size ?? .zero)
        return direction == .row ? HorizontalRenderer(size: size, children: children, positions: positions, mainAxisMaxValue: max) : VerticalRenderer(size: size, children: children, positions: positions, mainAxisMaxValue: max)
    }
}

extension FlexBox {
    public func layout(_ constraint: Constraint) -> Renderer {
        let mainMax = main(constraint.maxSize)
        let crossMax = cross(constraint.maxSize)
        var childConstraint = constraint
        var freezeMainSize: CGFloat = 0
        var renderers: [Renderer] = children.map { child in
            let rend = child.layout(constraint)
            freezeMainSize += main(childConstraint.maxSize)
            childConstraint.maxSize = size(main: main(childConstraint.maxSize) - main(rend.size), cross: cross(childConstraint.maxSize))
            return rend
        }
        
        var positions = [CGPoint]()
        
        var (mainOffset, mainSpacing) = LayoutHelper.distribute(justifyContent: justifyContent,
                                                                maxPrimary: mainMax,
                                                                totalPrimary: renderers.reduce(CGFloat(0), {$0+main($1.size)}),
                                                                minimunSpacing: 0,
                                                                numberOfItems: children.count)
        
        
        for (child, rend) in zip(children, renderers) {
            
        }
        
        return renderer(size: constraint.maxSize, children: renderers, positions: positions)
    }
}

public struct FlexBoxComponent: FlexBox {
    public var direction: FlexDirection
    public var justifyContent: MainAxisAlignment
    public var alignItems: CrossAxisAlignment
    public var alignContent: MainAxisAlignment
    public var children: [Component]
    public init(direction: FlexDirection = .row,
                justifyContent: MainAxisAlignment = .start,
                alignItems: CrossAxisAlignment = .start,
                alignContent: MainAxisAlignment = .start,
                @ComponentArrayBuilder _ content: () -> [Component]) {
        self.direction = direction
        self.justifyContent = justifyContent
        self.alignItems = alignItems
        self.alignContent = alignContent
        self.children = content()
    }
}
