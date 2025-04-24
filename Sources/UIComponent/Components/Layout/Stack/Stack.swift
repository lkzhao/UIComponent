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
        for (index, child) in renderNodes.enumerated() {
            var crossValue: CGFloat = 0
            let alignChild = children[index].contextValue(for: \.alignSelf) ?? alignItems
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
        lazy var childStretchConstraint = Constraint(
            minSize: size(main: -.infinity, cross: crossMaxConstraint != .infinity ? crossMaxConstraint : 0),
            maxSize: size(main: .infinity, cross: crossMaxConstraint)
        )
        for child in children {
            flexGrow += (child.contextValue(for: \.flexGrow) ?? 0)
            flexShrink += (child.contextValue(for: \.flexShrink) ?? 0)
            let childRenderNode: any RenderNode
            if alignItems != .stretch, child.contextValue(for: \.alignSelf) == .stretch {
                childRenderNode = child.layout(childStretchConstraint)
            } else {
                childRenderNode = child.layout(childConstraint)
            }
            let mainIntrinsic = main(childRenderNode.size)
            mainFreezed += mainIntrinsic.isFinite ? mainIntrinsic : 0
            renderNodes.append(childRenderNode)
        }

        let mainMax = main(constraint.maxSize)
        if flexGrow > 0, mainFreezed < mainMax {
            let mainPerFlex = mainMax == .infinity ? 0 : max(0, mainMax - mainFreezed) / flexGrow
            for (index, child) in children.enumerated() {
                let flexGrow = child.contextValue(for: \.flexGrow) ?? 0
                guard flexGrow > 0 else { continue }
                let alignChild = child.contextValue(for: \.alignSelf) ?? alignItems
                let childCrossMinConstraint = alignChild == .stretch && crossMaxConstraint != .infinity ? crossMaxConstraint : 0
                let addition = mainPerFlex * flexGrow
                let mainIntrinsic = main(renderNodes[index].size)
                let mainReserved = addition + (mainIntrinsic.isFinite ? mainIntrinsic : 0)
                let constraint = Constraint(
                    minSize: size(main: mainReserved, cross: childCrossMinConstraint),
                    maxSize: size(main: mainReserved, cross: crossMaxConstraint)
                )
                renderNodes[index] = child.layout(constraint)
                mainFreezed += addition
            }
        } else if flexShrink > 0, mainFreezed > mainMax {
            let mainPerFlex = mainMax == .infinity ? 0 : min(0, mainMax - mainFreezed) / flexShrink
            for (index, child) in children.enumerated() {
                let flexShrink = child.contextValue(for: \.flexShrink) ?? 0
                guard flexShrink > 0 else { continue }
                let alignChild = child.contextValue(for: \.alignSelf) ?? alignItems
                let childCrossMinConstraint = alignChild == .stretch && crossMaxConstraint != .infinity ? crossMaxConstraint : 0
                let mainReserved = mainPerFlex * flexShrink + main(renderNodes[index].size)
                let constraint = Constraint(
                    minSize: size(main: mainReserved, cross: childCrossMinConstraint),
                    maxSize: size(main: mainReserved, cross: crossMaxConstraint)
                )
                renderNodes[index] = child.layout(constraint)
                mainFreezed += mainReserved
            }
        }

        return renderNodes
    }
}
