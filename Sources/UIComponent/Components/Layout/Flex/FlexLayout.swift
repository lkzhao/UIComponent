//  Created by Luke Zhao on 8/24/20.

public extension RenderNodeContextKey {
    static let flexGrow = RenderNodeContextKey("flexGrow")
    static let flexShrink = RenderNodeContextKey("flexShrink")
    static let alignSelf = RenderNodeContextKey("alignSelf")
}

/// A protocol that defines the layout properties for flex layout.
/// Used by ``FlexRow`` (``Flow``) & ``FlexColumn``
public protocol FlexLayout: BaseLayoutProtocol {
    /// The space between lines in the flex layout.
    var lineSpacing: CGFloat { get }
    /// The space between items within a line.
    var interitemSpacing: CGFloat { get }
    /// The alignment of children within the main axis.
    var justifyContent: MainAxisAlignment { get }
    /// The alignment of children within the cross axis.
    var alignItems: CrossAxisAlignment { get }
    /// The alignment of lines within the cross axis when there is extra space in the container.
    var alignContent: MainAxisAlignment { get }
    /// The children components that the layout will arrange.
    var children: [any Component] { get }

    /// Initializes a new flex layout with the given parameters.
    /// - Parameters:
    ///   - lineSpacing: The space between lines in the flex layout.
    ///   - interitemSpacing: The space between items within a line.
    ///   - justifyContent: The alignment of children within the main axis.
    ///   - alignItems: The alignment of children within the cross axis.
    ///   - alignContent: The alignment of lines within the cross axis when there is extra space in the container.
    ///   - children: The children components that the layout will arrange.
    init(
        lineSpacing: CGFloat,
        interitemSpacing: CGFloat,
        justifyContent: MainAxisAlignment,
        alignItems: CrossAxisAlignment,
        alignContent: MainAxisAlignment,
        children: [any Component]
    )
}

extension FlexLayout {
    /// Initializes a new flex layout with the given parameters and a closure that builds the children components.
    /// - Parameters:
    ///   - lineSpacing: The space between lines in the flex layout. Defaults to 0.
    ///   - interitemSpacing: The space between items within a line. Defaults to 0.
    ///   - justifyContent: The alignment of children within the main axis. Defaults to `.start`.
    ///   - alignItems: The alignment of children within the cross axis. Defaults to `.start`.
    ///   - alignContent: The alignment of lines within the cross axis when there is extra space in the container. Defaults to `.start`.
    ///   - content: A closure that returns an array of children components using the `ComponentArrayBuilder`.
    public init(
        lineSpacing: CGFloat = 0,
        interitemSpacing: CGFloat = 0,
        justifyContent: MainAxisAlignment = .start,
        alignItems: CrossAxisAlignment = .start,
        alignContent: MainAxisAlignment = .start,
        @ComponentArrayBuilder _ content: () -> [any Component]
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

    /// Initializes a new flex layout with the given parameters and an array of children components.
    /// - Parameters:
    ///   - spacing: The space between lines and items within a line in the flex layout. Defaults to 0.
    ///   - justifyContent: The alignment of children within the main axis. Defaults to `.start`.
    ///   - alignItems: The alignment of children within the cross axis. Defaults to `.start`.
    ///   - alignContent: The alignment of lines within the cross axis when there is extra space in the container. Defaults to `.start`.
    ///   - children: An array of children components.
    public init(
        spacing: CGFloat = 0,
        justifyContent: MainAxisAlignment = .start,
        alignItems: CrossAxisAlignment = .start,
        alignContent: MainAxisAlignment = .start,
        children: [any Component]
    ) {
        self.init(lineSpacing: spacing, interitemSpacing: spacing, justifyContent: justifyContent, alignItems: alignItems, alignContent: alignContent, children: children)
    }

    /// Initializes a new flex layout with the given parameters and a closure that builds the children components.
    /// - Parameters:
    ///   - spacing: The space between lines and items within a line in the flex layout. Defaults to 0.
    ///   - justifyContent: The alignment of children within the main axis. Defaults to `.start`.
    ///   - alignItems: The alignment of children within the cross axis. Defaults to `.start`.
    ///   - alignContent: The alignment of lines within the cross axis when there is extra space in the container. Defaults to `.start`.
    ///   - content: A closure that returns an array of children components using the `ComponentArrayBuilder`.
    public init(
        spacing: CGFloat = 0,
        justifyContent: MainAxisAlignment = .start,
        alignItems: CrossAxisAlignment = .start,
        alignContent: MainAxisAlignment = .start,
        @ComponentArrayBuilder _ content: () -> [any Component]
    ) {
        self.init(spacing: spacing, justifyContent: justifyContent, alignItems: alignItems, alignContent: alignContent, children: content())
    }
}

extension FlexLayout {
    public func layout(_ constraint: Constraint) -> R {
        // Determine the maximum size along the main and cross axis based on the given constraint.
        let mainMax = main(constraint.maxSize)
        let crossMax = cross(constraint.maxSize)

        // Create a new constraint for children with infinite main size and maximum cross size.
        let childConstraint = Constraint(maxSize: size(main: .infinity, cross: crossMax))

        // Layout all children with the new constraint and collect their render nodes.
        var renderNodes: [any RenderNode] = children.map {
            $0.layout(childConstraint)
        }

        // Initialize an array to store the position of each child.
        var positions: [CGPoint] = []

        // Initialize variables to calculate the size of each line and the total height.
        var lineData: [(lineSize: CGSize, count: Int)] = []
        var currentLineItemCount = 0
        var currentLineWidth: CGFloat = 0
        var currentLineMaxHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        // Iterate over the render nodes to calculate the size of each line.
        for renderNode in renderNodes {
            let itemWidth = cross(renderNode.size)
            let itemHeight = main(renderNode.size)

            // Change: If not the first item, check if adding spacing and the item exceeds crossMax.
            if currentLineItemCount > 0, currentLineWidth + interitemSpacing + itemWidth > crossMax {
                // Save the current line data without subtracting extra spacing.
                lineData.append(
                    (
                        lineSize: size(
                            main: currentLineMaxHeight,
                            cross: currentLineWidth
                        ),
                        count: currentLineItemCount
                    )
                )
                totalHeight += currentLineMaxHeight
                currentLineMaxHeight = 0
                currentLineWidth = 0
                currentLineItemCount = 0
            }
            // Change: Only add interitemSpacing if this is not the first item.
            if currentLineItemCount > 0 {
                currentLineWidth += interitemSpacing
            }
            // Update the current line's max height and width, and increment the item count.
            currentLineWidth += itemWidth
            currentLineMaxHeight = max(currentLineMaxHeight, itemHeight)
            currentLineItemCount += 1
        }

        // Add the last line data if there are items in it.
        if currentLineItemCount > 0 {
            lineData.append(
                (
                    lineSize: size(
                        main: currentLineMaxHeight,
                        cross: currentLineWidth
                    ),
                    count: currentLineItemCount
                )
            )
            totalHeight += currentLineMaxHeight
        }

        // Calculate the starting offset and spacing for the main axis based on the alignContent property.
        var (mainOffset, mainSpacing) = LayoutHelper.distribute(
            justifyContent: alignContent,
            maxPrimary: mainMax,
            totalPrimary: totalHeight,
            minimumSpacing: lineSpacing,
            numberOfItems: lineData.count
        )

        // Iterate over each line to layout the items within.
        var lineStartIndex = 0
        for (var lineSize, count) in lineData {
            let range = lineStartIndex..<(lineStartIndex + count)

            // Calculate the total flex grow values for items in the current line.
            let flexCount = renderNodes[range].reduce(0) { result, next in
                result + next.flexGrow
            }

            // If there are flexible items and the cross max size is not infinite, adjust their sizes.
            if flexCount > 0, crossMax != .infinity {
                let crossPerFlex = max(0, crossMax - cross(lineSize)) / flexCount
                for index in range {
                    let childNode = renderNodes[index]
                    let flexGrow = childNode.flexGrow
                    let alignSelf = childNode.alignSelf
                    if flexGrow > 0 || alignSelf != nil  {
                        let child = children[index]
                        let alignChild = alignSelf ?? alignItems
                        let crossReserved = crossPerFlex * flexGrow + cross(renderNodes[index].size)
                        let constraint = Constraint(
                            minSize: size(main: (alignChild == .stretch) ? main(lineSize) : 0, cross: crossReserved),
                            maxSize: size(main: .infinity, cross: crossReserved)
                        )
                        renderNodes[index] = child.layout(constraint)
                    }
                }
                lineSize = size(main: main(lineSize), cross: crossMax)
            }

            // If there are baseline-aligned items, calculate its baseline
            // and adjust the line's main size if needed.
            var lineStartToBaselineMax: CGFloat = 0
            var lineBaselineToEndMax: CGFloat = 0
            for index in range {
                let renderNode = renderNodes[index]
                let itemAlign = renderNode.alignSelf ?? alignItems

                if itemAlign == .baselineFirst || itemAlign == .baselineLast {
                    let itemMain = main(renderNode.size)
                    let itemBaseline = (itemAlign == .baselineFirst) ? renderNode.ascender : (itemMain + renderNode.descender)
                    lineStartToBaselineMax = max(lineStartToBaselineMax, itemBaseline)
                    lineBaselineToEndMax = max(lineBaselineToEndMax, itemMain - itemBaseline)
                }
            }
            let lineMain = max(lineStartToBaselineMax + lineBaselineToEndMax, main(lineSize))
            lineSize = size(main: lineMain, cross: cross(lineSize))
            let lineBaseline = lineStartToBaselineMax

            // Calculate the starting offset and spacing for the cross axis based on the justifyContent property.
            var (crossOffset, crossSpacing) = LayoutHelper.distribute(
                justifyContent: justifyContent,
                maxPrimary: crossMax,
                totalPrimary: cross(lineSize),
                minimumSpacing: interitemSpacing,
                numberOfItems: count
            )

            // Layout the items in the current line and calculate their positions.
            for (itemIndex, var child) in renderNodes[lineStartIndex..<(lineStartIndex + count)].enumerated() {
                let childComponent = children[lineStartIndex + itemIndex]
                if alignItems == .stretch, main(child.size) != main(lineSize) {
                    // If alignItems is stretch and the child's main size is not equal to the line's main size, relayout the child.
                    child = childComponent.layout(
                        Constraint(
                            minSize: size(main: main(lineSize), cross: -.infinity),
                            maxSize: size(main: main(lineSize), cross: crossMax)
                        )
                    )
                    renderNodes[lineStartIndex + itemIndex] = child
                }
                // Calculate the alignment value based on the alignSelf property or the default alignItems.
                var alignValue: CGFloat = 0
                let alignChild = child.alignSelf ?? alignItems
                switch alignChild {
                case .start, .stretch:
                    alignValue = 0
                case .end:
                    alignValue = main(lineSize) - main(child.size)
                case .center:
                    alignValue = (main(lineSize) - main(child.size)) / 2
                case .baselineFirst:
                    alignValue = lineBaseline - child.ascender
                case .baselineLast:
                    alignValue = lineBaseline - (main(child.size) + child.descender)
                }
                // Set the position for the current child.
                positions.append(point(main: mainOffset + alignValue, cross: crossOffset))
                crossOffset += cross(child.size) + crossSpacing
            }

            // Update the main offset for the next line and increment the line start index.
            mainOffset += main(lineSize) + mainSpacing
            lineStartIndex += count
        }

        // Calculate the intrinsic main size and the final size of the layout.
        let intrisicMain = mainOffset - mainSpacing
        let finalMain = alignContent != .start && mainMax != .infinity ? max(mainMax, intrisicMain) : intrisicMain
        let finalSize = size(main: finalMain, cross: crossMax)

        // Return the render node with the final size and positions of children.
        return renderNode(size: finalSize, children: renderNodes, positions: positions)
    }
}


extension RenderNode {
    internal var flexGrow: CGFloat {
        contextValue(.flexGrow) as? CGFloat ?? 0
    }
    internal var flexShrink: CGFloat {
        contextValue(.flexShrink) as? CGFloat ?? 0
    }
    internal var alignSelf: CrossAxisAlignment? {
        contextValue(.alignSelf) as? CrossAxisAlignment
    }
}
