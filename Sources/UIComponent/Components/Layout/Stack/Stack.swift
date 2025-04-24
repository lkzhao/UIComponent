//  Created by Luke Zhao on 8/22/20.

import UIKit

/// A protocol representing a stack layout and provide the stack layout implementation.
public protocol Stack: BaseLayoutProtocol {
    /// The space between adjacent children in the stack.
    var spacing: CGFloat { get }
    /// The distribution of children along the main axis.
    var justifyContent: MainAxisAlignment { get }
    /// The alignment of children along the cross axis.
    var alignItems: CrossAxisAlignment { get }
    /// The child components within the stack.
    var children: [any Component] { get }
}

extension Stack {
    public func layout(_ constraint: Constraint) -> R {
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
        let primaryBound = minPrimary > 0 ? minPrimary : maxPrimary
        let (offset, distributedSpacing) = LayoutHelper.distribute(
            justifyContent: justifyContent,
            maxPrimary: primaryBound,
            totalPrimary: mainTotal,
            minimunSpacing: spacing,
            numberOfItems: renderNodes.count
        )

        var primaryOffset = offset
        var positions: [CGPoint] = []
        for child in renderNodes {
            var crossValue: CGFloat = 0
            let alignChild = child.contextValue(.alignSelf) as? CrossAxisAlignment ?? alignItems
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
        let shouldFillPrimary = justifyContent != .start && primaryBound != .infinity
        let finalMain = max(shouldFillPrimary ? primaryBound : minPrimary, intrisicMain)
        let finalSize = size(main: finalMain, cross: crossMax)

        return renderNode(size: finalSize, children: renderNodes, positions: positions)
    }

    func getRenderNodes(_ constraint: Constraint) -> [any RenderNode] {
        var renderNodes: [any RenderNode] = []

        let spacings = spacing * CGFloat(children.count - 1)
        var mainFreezed: CGFloat = spacings
        var flexGrow: CGFloat = 0
        var flexShrink: CGFloat = 0
        let crossMaxConstraint = cross(constraint.maxSize)
        let crossMinConstraint = alignItems == .stretch && crossMaxConstraint != .infinity ? crossMaxConstraint : 0

        let childConstraint = Constraint(
            minSize: size(main: -.infinity, cross: crossMinConstraint),
            maxSize: size(main: .infinity, cross: crossMaxConstraint)
        )

        var stretchedItems: Set<Int> = []
        var flexGrowPerItem: [Int: CGFloat] = [:]
        var flexShrinkPerItem: [Int: CGFloat] = [:]
        var updatedConstraint: [Int: Constraint] = [:]
        for child in children {
            let childRenderNode = child.layout(childConstraint)
            let childGrow = childRenderNode.contextValue(.flexGrow) as? CGFloat ?? 0
            let childShrink = childRenderNode.contextValue(.flexShrink) as? CGFloat ?? 0

            flexGrow += childGrow
            flexShrink += childShrink
            if childGrow > 0 {
                flexGrowPerItem[renderNodes.count] = childGrow
            }
            if childShrink > 0 {
                flexShrinkPerItem[renderNodes.count] = childShrink
            }
            if alignItems != .stretch, childRenderNode.contextValue(.alignSelf) as? CrossAxisAlignment == .stretch {
                stretchedItems.insert(renderNodes.count)
            }

            let mainIntrinsic = main(childRenderNode.size)
            mainFreezed += mainIntrinsic.isFinite ? mainIntrinsic : 0
            renderNodes.append(childRenderNode)
        }

        let mainMax = main(constraint.maxSize)
        if flexGrow > 0, mainFreezed < mainMax {
            let mainPerFlex = mainMax == .infinity ? 0 : max(0, mainMax - mainFreezed) / flexGrow
            for (index, grow) in flexGrowPerItem {
                let childCrossMinConstraint = stretchedItems.contains(index) && crossMaxConstraint != .infinity ? crossMaxConstraint : crossMinConstraint
                let addition = mainPerFlex * grow
                let mainIntrinsic = main(renderNodes[index].size)
                let mainReserved = addition + (mainIntrinsic.isFinite ? mainIntrinsic : 0)
                let constraint = Constraint(
                    minSize: size(main: mainReserved, cross: childCrossMinConstraint),
                    maxSize: size(main: mainReserved, cross: crossMaxConstraint)
                )
                updatedConstraint[index] = constraint
                stretchedItems.remove(index)
            }
        }
        if flexShrink > 0, mainFreezed > mainMax {
            let mainPerFlex = mainMax == .infinity ? 0 : min(0, mainMax - mainFreezed) / flexShrink
            for (index, shrink) in flexShrinkPerItem {
                let childCrossMinConstraint = stretchedItems.contains(index) && crossMaxConstraint != .infinity ? crossMaxConstraint : crossMinConstraint
                let mainReserved = mainPerFlex * shrink + main(renderNodes[index].size)
                let constraint = Constraint(
                    minSize: size(main: mainReserved, cross: childCrossMinConstraint),
                    maxSize: size(main: mainReserved, cross: crossMaxConstraint)
                )
                updatedConstraint[index] = constraint
                stretchedItems.remove(index)
            }
        }
        if !stretchedItems.isEmpty {
            let stretchedConstraint = Constraint(
                minSize: size(main: -.infinity, cross: crossMaxConstraint != .infinity ? crossMaxConstraint : 0),
                maxSize: size(main: .infinity, cross: crossMaxConstraint)
            )
            for index in stretchedItems {
                updatedConstraint[index] = stretchedConstraint
            }
        }

        for (index, constraint) in updatedConstraint {
            let childRenderNode = children[index].layout(constraint)
            renderNodes[index] = childRenderNode
        }

        return renderNodes
    }
}
