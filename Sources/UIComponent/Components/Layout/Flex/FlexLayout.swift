//  Created by Luke Zhao on 8/24/20.

@_implementationOnly import BaseToolbox
import UIKit

/// Implementation for `FlexColumn` & `FlexRow`
public protocol FlexLayout: Component, BaseLayoutProtocol {
    var lineSpacing: CGFloat { get }
    var interitemSpacing: CGFloat { get }
    var justifyContent: MainAxisAlignment { get }
    var alignItems: CrossAxisAlignment { get }
    var alignContent: MainAxisAlignment { get }
    var children: [Component] { get }

    init(
        lineSpacing: CGFloat,
        interitemSpacing: CGFloat,
        justifyContent: MainAxisAlignment,
        alignItems: CrossAxisAlignment,
        alignContent: MainAxisAlignment,
        children: [Component]
    )
}

extension FlexLayout {
    public init(
        lineSpacing: CGFloat = 0,
        interitemSpacing: CGFloat = 0,
        justifyContent: MainAxisAlignment = .start,
        alignItems: CrossAxisAlignment = .start,
        alignContent: MainAxisAlignment = .start,
        @ComponentArrayBuilder _ content: () -> [Component]
    ) {
        self.init(
            lineSpacing: lineSpacing,
            interitemSpacing: interitemSpacing,
            justifyContent: justifyContent,
            alignItems: alignItems,
            alignContent: alignContent,
            children: content()
        )
    }
    public init(
        spacing: CGFloat = 0,
        justifyContent: MainAxisAlignment = .start,
        alignItems: CrossAxisAlignment = .start,
        alignContent: MainAxisAlignment = .start,
        @ComponentArrayBuilder _ content: () -> [Component]
    ) {
        self.init(lineSpacing: spacing, interitemSpacing: spacing, justifyContent: justifyContent, alignItems: alignItems, alignContent: alignContent, children: content())
    }
}

extension FlexLayout {
    public func layout(_ constraint: Constraint) -> RenderNode {
        let mainMax = main(constraint.maxSize)
        let crossMax = cross(constraint.maxSize)
        let childConstraint = Constraint(maxSize: size(main: .infinity, cross: crossMax))
        var renderNodes: [RenderNode] = children.map {
            $0.layout(childConstraint)
        }
        var positions: [CGPoint] = []

        // calculate line size base on item sizes
        var lineData: [(lineSize: CGSize, count: Int)] = []
        var currentLineItemCount = 0
        var currentLineWidth: CGFloat = 0
        var currentLineMaxHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        for renderNode in renderNodes {
            if currentLineWidth + cross(renderNode.size) > crossMax, currentLineItemCount != 0 {
                lineData.append(
                    (
                        lineSize: size(
                            main: currentLineMaxHeight,
                            cross: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing
                        ),
                        count: currentLineItemCount
                    )
                )
                totalHeight += currentLineMaxHeight
                currentLineMaxHeight = 0
                currentLineWidth = 0
                currentLineItemCount = 0
            }
            currentLineMaxHeight = max(currentLineMaxHeight, main(renderNode.size))
            currentLineWidth += cross(renderNode.size) + interitemSpacing
            currentLineItemCount += 1
        }
        if currentLineItemCount > 0 {
            lineData.append(
                (
                    lineSize: size(
                        main: currentLineMaxHeight,
                        cross: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing
                    ),
                    count: currentLineItemCount
                )
            )
            totalHeight += currentLineMaxHeight
        }

        var (mainOffset, mainSpacing) = LayoutHelper.distribute(
            justifyContent: alignContent,
            maxPrimary: mainMax,
            totalPrimary: totalHeight,
            minimunSpacing: lineSpacing,
            numberOfItems: lineData.count
        )

        // layout each line
        var lineStartIndex = 0
        for (var lineSize, count) in lineData {
            let range = lineStartIndex..<(lineStartIndex + count)

            // resize flex items
            let flexCount = children[range]
                .reduce(0) { result, next in
                    result + ((next as? Flexible)?.flexGrow ?? 0)
                }
            if flexCount > 0, crossMax != .infinity {
                let crossPerFlex = max(0, crossMax - cross(lineSize)) / flexCount
                for index in range {
                    let child = children[index]
                    if let child = child as? Flexible {
                        let alignChild = child.alignSelf ?? alignItems
                        let crossReserved = crossPerFlex * child.flexGrow + cross(renderNodes[index].size)
                        let constraint = Constraint(
                            minSize: size(main: (alignChild == .stretch) ? main(lineSize) : 0, cross: crossReserved),
                            maxSize: size(main: .infinity, cross: crossReserved)
                        )
                        renderNodes[index] = child.layout(constraint)
                    }
                }
                lineSize = size(main: main(lineSize), cross: crossMax)
            }

            // distribute on the cross axis
            var (crossOffset, crossSpacing) = LayoutHelper.distribute(
                justifyContent: justifyContent,
                maxPrimary: crossMax,
                totalPrimary: cross(lineSize),
                minimunSpacing: interitemSpacing,
                numberOfItems: count
            )

            // finally, layout all of the items on this line
            for (itemIndex, var child) in renderNodes[lineStartIndex..<(lineStartIndex + count)].enumerated() {
                let childComponent = children[lineStartIndex + itemIndex]
                if alignItems == .stretch, main(child.size) != main(lineSize) {
                    // relayout items with a fixed main size
                    child = childComponent.layout(
                        Constraint(
                            minSize: size(main: main(lineSize), cross: -.infinity),
                            maxSize: size(main: main(lineSize), cross: crossMax)
                        )
                    )
                    renderNodes[lineStartIndex + itemIndex] = child
                }
                var alignValue: CGFloat = 0
                let alignChild = (childComponent as? Flexible)?.alignSelf ?? alignItems
                switch alignChild {
                case .start, .stretch:
                    alignValue = 0
                case .end:
                    alignValue = main(lineSize) - main(child.size)
                case .center:
                    alignValue = (main(lineSize) - main(child.size)) / 2
                }
                positions.append(point(main: mainOffset + alignValue, cross: crossOffset))
                crossOffset += cross(child.size) + crossSpacing
            }

            mainOffset += main(lineSize) + mainSpacing
            lineStartIndex += count
        }

        let intrisicMain = mainOffset - mainSpacing
        let finalMain = alignContent != .start && mainMax != .infinity ? max(mainMax, intrisicMain) : intrisicMain
        let finalSize = size(main: finalMain, cross: crossMax)
        return renderNode(size: finalSize, children: renderNodes, positions: positions)
    }
}
