//  Created by Luke Zhao on 8/23/20.

/// A protocol that defines the requirements for a waterfall layout.
/// A waterfall layout is a type of layout that arranges items in multiple columns with varying item heights.
/// - Parameters:
///   - columns: The number of columns in the layout.
///   - spacing: The spacing between items in the layout.
///   - children: The components that will be laid out according to the waterfall layout.
public protocol WaterfallLayoutProtocol: BaseLayoutProtocol {
    var columns: Int { get }
    var spacing: CGFloat { get }
    var children: [any Component] { get }
}

extension WaterfallLayoutProtocol {
    public func layout(_ constraint: Constraint) -> R {
        var renderNodes: [any RenderNode] = []
        var positions: [CGPoint] = []

        let columnWidth = (cross(constraint.maxSize) - CGFloat(columns - 1) * spacing) / CGFloat(columns)
        var columnHeight = [CGFloat](repeating: 0, count: columns)

        func getMinColomn() -> (Int, CGFloat) {
            var minHeight: (Int, CGFloat) = (0, columnHeight[0])
            for (index, height) in columnHeight.enumerated() where height < minHeight.1 {
                minHeight = (index, height)
            }
            return minHeight
        }

        for child in children {
            let renderNode = child.layout(
                Constraint(
                    minSize: size(main: 0, cross: columnWidth),
                    maxSize: size(main: .infinity, cross: columnWidth)
                )
            )
            let (columnIndex, offsetY) = getMinColomn()
            columnHeight[columnIndex] += main(renderNode.size) + spacing
            renderNodes.append(renderNode)
            positions.append(point(main: offsetY, cross: CGFloat(columnIndex) * (columnWidth + spacing)))
        }

        return renderNode(
            size: size(main: max(0, columnHeight.max()! - spacing), cross: cross(constraint.maxSize)),
            children: renderNodes,
            positions: positions
        )
    }
}

/// A `Waterfall` represents a vertical waterfall layout, which arranges items in multiple columns with varying item heights, similar to a masonry layout.
public struct Waterfall: Component, WaterfallLayoutProtocol, VerticalLayoutProtocol {
    /// The number of columns in the layout.
    public var columns: Int
    /// The spacing between items in the layout.
    public var spacing: CGFloat
    /// The components that will be laid out according to the waterfall layout.
    public var children: [any Component]

    /// Initializes a new `Waterfall` layout with the specified number of columns, spacing, and child components.
    /// - Parameters:
    ///   - columns: The number of columns in the layout. Defaults to 2.
    ///   - spacing: The spacing between items in the layout. Defaults to 0.
    ///   - children: The components that will be laid out according to the waterfall layout. Defaults to an empty array.
    public init(columns: Int = 2, spacing: CGFloat = 0, children: [any Component] = []) {
        self.columns = columns
        self.spacing = spacing
        self.children = children
    }
}

/// A `HorizontalWaterfall` represents a horizontal waterfall layout, which arranges items in multiple rows with varying item widths, similar to a masonry layout in a horizontal orientation.
public struct HorizontalWaterfall: Component, WaterfallLayoutProtocol, HorizontalLayoutProtocol {
    /// The number of rows in the layout.
    public var columns: Int
    /// The spacing between items in the layout.
    public var spacing: CGFloat
    /// The components that will be laid out according to the horizontal waterfall layout.
    public var children: [any Component]
    /// Initializes a new `HorizontalWaterfall` layout with the specified number of rows, spacing, and child components.
    /// - Parameters:
    ///   - columns: The number of rows in the layout. Defaults to 2.
    ///   - spacing: The spacing between items in the layout. Defaults to 0.
    ///   - children: The components that will be laid out according to the horizontal waterfall layout. Defaults to an empty array.
    public init(columns: Int = 2, spacing: CGFloat = 0, children: [any Component] = []) {
        self.columns = columns
        self.spacing = spacing
        self.children = children
    }
}

extension Waterfall {
    /// Initializes a new ``Waterfall`` layout with the specified number of columns, spacing, and child components.
    /// This initializer allows for a trailing closure syntax to define the child components using a ``ComponentArrayBuilder``.
    /// - Parameters:
    ///   - columns: The number of columns in the layout. Defaults to 2.
    ///   - spacing: The spacing between items in the layout. Defaults to 0.
    ///   - content: A result builder closure that returns an array of components to be laid out in the waterfall layout.
    public init(columns: Int = 2, spacing: CGFloat = 0, @ComponentArrayBuilder _ content: () -> [any Component]) {
        self.init(columns: columns, spacing: spacing, children: content())
    }
}

extension HorizontalWaterfall {
    /// Initializes a new ``HorizontalWaterfall`` layout with the specified number of rows, spacing, and child components using a result builder.
    /// This initializer allows for a trailing closure syntax to define the child components using a ``ComponentArrayBuilder``.
    /// - Parameters:
    ///   - columns: The number of rows in the layout. Defaults to 2.
    ///   - spacing: The spacing between items in the layout. Defaults to 0.
    ///   - content: A result builder closure that returns an array of components to be laid out in the horizontal waterfall layout.
    public init(columns: Int = 2, spacing: CGFloat = 0, @ComponentArrayBuilder _ content: () -> [any Component]) {
        self.init(columns: columns, spacing: spacing, children: content())
    }
}
