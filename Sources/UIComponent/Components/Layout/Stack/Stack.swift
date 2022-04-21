//  Created by Luke Zhao on 8/22/20.

import UIKit

public protocol Stack: Component, BaseLayoutProtocol {
    var spacing: CGFloat { get }
    var justifyContent: MainAxisAlignment { get }
    var alignItems: CrossAxisAlignment { get }
    var children: [Component] { get }
}

extension Stack {
    public func layout(_ constraint: Constraint) -> RenderNode {
        var renderNodes = getRenderNodes(constraint)
        let crossMax = renderNodes.reduce(CGFloat(0).clamp(cross(constraint.minSize), cross(constraint.maxSize))) {
            max($0, cross($1.size))
        }
        if cross(constraint.maxSize) == .infinity, alignItems == .stretch {
            // when using alignItem = .stretch, we need to relayout child to stretch its cross axis
            renderNodes = getRenderNodes(
                Constraint(
                    minSize: constraint.minSize,
                    maxSize: size(main: main(constraint.maxSize), cross: crossMax)
                )
            )
        }
        let mainTotal = renderNodes.reduce(0) {
            $0 + main($1.size)
        }

        let maxPrimary = main(constraint.maxSize)
        let minPrimary = main(constraint.minSize)
        let (offset, distributedSpacing) = LayoutHelper.distribute(
            justifyContent: justifyContent,
            maxPrimary: maxPrimary == .infinity && minPrimary > 0 ? minPrimary : maxPrimary,
            totalPrimary: mainTotal,
            minimunSpacing: spacing,
            numberOfItems: renderNodes.count
        )

        var primaryOffset = offset
        var positions: [CGPoint] = []
        for (index, child) in renderNodes.enumerated() {
            var crossValue: CGFloat = 0
            let alignChild = (children[index] as? Flexible)?.alignSelf ?? alignItems
            switch alignChild {
            case .start:
                crossValue = 0
            case .end:
                crossValue = crossMax - cross(child.size)
            case .center:
                crossValue = (crossMax - cross(child.size)) / 2
            case .stretch:
                crossValue = 0
            }
            positions.append(point(main: primaryOffset, cross: crossValue))
            primaryOffset += main(child.size) + distributedSpacing
        }
        let intrisicMain = primaryOffset - distributedSpacing
        let finalMain = justifyContent != .start && main(constraint.maxSize) != .infinity ? max(main(constraint.maxSize), intrisicMain) : intrisicMain
        let finalSize = size(main: finalMain, cross: crossMax)

        return renderNode(size: finalSize, children: renderNodes, positions: positions)
    }

    func getRenderNodes(_ constraint: Constraint) -> [RenderNode] {
        var renderNodes: [RenderNode] = []

        let spacings = spacing * CGFloat(children.count - 1)
        var mainFreezed: CGFloat = spacings
        var flexGrow: CGFloat = 0
        var flexShrink: CGFloat = 0
        let crossMaxConstraint = cross(constraint.maxSize)

        let childConstraint = Constraint(
            minSize: size(main: -.infinity, cross: alignItems == .stretch && crossMaxConstraint != .infinity ? crossMaxConstraint : 0),
            maxSize: size(main: .infinity, cross: cross(constraint.maxSize))
        )
        for child in children {
            if let flexChild = child as? Flexible {
                flexGrow += flexChild.flexGrow
                flexShrink += flexChild.flexShrink
            }
            let childRenderNode = child.layout(childConstraint)
            mainFreezed += main(childRenderNode.size)
            renderNodes.append(childRenderNode)
        }

        let mainMax = main(constraint.maxSize)
        if flexGrow > 0, mainFreezed < mainMax {
            let mainPerFlex = mainMax == .infinity ? 0 : max(0, mainMax - mainFreezed) / flexGrow
            for (index, child) in children.enumerated() {
                if let child = child as? Flexible, child.flexGrow > 0 {
                    let alignChild = child.alignSelf ?? alignItems
                    let addition = mainPerFlex * child.flexGrow
                    let mainReserved = addition + renderNodes[index].size.width
                    let constraint = Constraint(
                        minSize: size(main: mainReserved, cross: (alignChild == .stretch) ? cross(constraint.maxSize) : 0),
                        maxSize: size(main: mainReserved, cross: cross(constraint.maxSize))
                    )
                    renderNodes[index] = child.layout(constraint)
                    mainFreezed += addition
                }
            }
        } else if flexShrink > 0, mainFreezed > mainMax {
            let mainPerFlex = mainMax == .infinity ? 0 : min(0, mainMax - mainFreezed) / flexShrink
            for (index, child) in children.enumerated() {
                if let child = child as? Flexible, child.flexShrink > 0 {
                    let alignChild = child.alignSelf ?? alignItems
                    let mainReserved = mainPerFlex * child.flexShrink + renderNodes[index].size.width
                    let constraint = Constraint(
                        minSize: size(main: mainReserved, cross: (alignChild == .stretch) ? cross(constraint.maxSize) : 0),
                        maxSize: size(main: mainReserved, cross: cross(constraint.maxSize))
                    )
                    renderNodes[index] = child.layout(constraint)
                    mainFreezed += mainReserved
                }
            }
        }

        return renderNodes
    }
}
