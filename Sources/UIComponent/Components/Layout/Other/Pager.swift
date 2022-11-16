
import UIKit

public protocol Pager: Component, BaseLayoutProtocol {
    var alignItems: CrossAxisAlignment { get }
    var children: [Component] { get }
}

extension Pager {
    public func layout(_ constraint: Constraint) -> RenderNode {
        let isUnbounded = main(constraint.maxSize) == .infinity
        guard !isUnbounded else {
            let error = "Pager cannot be wrapped under an unlimited constraint component on its main axis. e.g. under a HStack or VStack"
            assertionFailure(error)
            return Text(verbatim: error).textColor(.red).layout(constraint)
        }
        let pageMain = main(constraint.maxSize)
        let childConstraint = Constraint(minSize: size(main: pageMain, cross: cross(constraint.minSize)),
                                         maxSize: size(main: pageMain, cross: cross(constraint.maxSize)))
        var renderNodes: [RenderNode] = []
        var crossMax: CGFloat = 0
        for child in children {
            let node = child.layout(childConstraint)
            renderNodes.append(node)
            crossMax = max(cross(node.size), crossMax)
        }
        var positions: [CGPoint] = []
        for (index, child) in renderNodes.enumerated() {
            var crossValue: CGFloat = 0
            switch alignItems {
            case .start:
                crossValue = 0
            case .end:
                crossValue = crossMax - cross(child.size)
            case .center:
                crossValue = (crossMax - cross(child.size)) / 2
            case .stretch:
                crossValue = 0
            }
            positions.append(point(main: CGFloat(index) * pageMain, cross: crossValue))
        }
        return renderNode(size: size(main: CGFloat(children.count) * pageMain, cross: crossMax), children: renderNodes, positions: positions)
    }
}

public struct HPager: Pager, HorizontalLayoutProtocol {
    public let alignItems: CrossAxisAlignment
    public let children: [Component]
    public init(alignItems: CrossAxisAlignment = .start, children: [Component] = []) {
        self.alignItems = alignItems
        self.children = children
    }
}

extension HPager {
    public init(alignItems: CrossAxisAlignment = .start, @ComponentArrayBuilder _ content: () -> [Component]) {
        self.init(alignItems: alignItems, children: content())
    }
}

public struct VPager: Pager, VerticalLayoutProtocol {
    public let alignItems: CrossAxisAlignment
    public let children: [Component]
    public init(alignItems: CrossAxisAlignment = .start, children: [Component] = []) {
        self.alignItems = alignItems
        self.children = children
    }
}

extension VPager {
    public init(alignItems: CrossAxisAlignment = .start, @ComponentArrayBuilder _ content: () -> [Component]) {
        self.init(alignItems: alignItems, children: content())
    }
}

