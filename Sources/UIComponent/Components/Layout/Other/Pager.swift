
import UIKit

public protocol Pager: BaseLayoutProtocol {
    var alignItems: CrossAxisAlignment { get }
    var children: [any Component] { get }
}

extension Pager {
    public func layout(_ constraint: Constraint) -> R {
        let isUnbounded = main(constraint.maxSize) == .infinity
        guard !isUnbounded else {
            let error = "Pager cannot be wrapped under an unlimited constraint component on its main axis. e.g. under a HStack or VStack"
            assertionFailure(error)
            let child = Text(error).textColor(.red)
            let childNode = child.layout(constraint)
            return renderNode(size: childNode.size, children: [childNode], positions: [.zero])
        }
        let pageMain = main(constraint.maxSize)
        let childConstraint = Constraint(minSize: size(main: pageMain, cross: cross(constraint.minSize)),
                                         maxSize: size(main: pageMain, cross: cross(constraint.maxSize)))
        var renderNodes: [any RenderNode] = []
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

public struct HPager: Component, Pager, HorizontalLayoutProtocol {
    public let alignItems: CrossAxisAlignment
    public let children: [any Component]
    public init(alignItems: CrossAxisAlignment = .start, children: [any Component] = []) {
        self.alignItems = alignItems
        self.children = children
    }
}

extension HPager {
    public init(alignItems: CrossAxisAlignment = .start, @ComponentArrayBuilder _ content: () -> [any Component]) {
        self.init(alignItems: alignItems, children: content())
    }
}

public struct VPager: Component, Pager, VerticalLayoutProtocol {
    public let alignItems: CrossAxisAlignment
    public let children: [any Component]
    public init(alignItems: CrossAxisAlignment = .start, children: [any Component] = []) {
        self.alignItems = alignItems
        self.children = children
    }
}

extension VPager {
    public init(alignItems: CrossAxisAlignment = .start, @ComponentArrayBuilder _ content: () -> [any Component]) {
        self.init(alignItems: alignItems, children: content())
    }
}

