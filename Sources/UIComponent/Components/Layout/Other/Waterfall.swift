//  Created by Luke Zhao on 8/23/20.

/// A protocol that defines the requirements for a waterfall layout.
/// A waterfall layout is a type of layout that arranges items in multiple columns with varying item heights.
/// - Parameters:
///   - columns: The number of columns in the layout.
///   - columnSpacing: The spacing between columns in the layout.
///   - interItemSpacing: The spacing between items within each column.
///   - children: The components that will be laid out according to the waterfall layout.
public protocol WaterfallLayoutProtocol: BaseLayoutProtocol {
    var columns: Int { get }
    var columnSpacing: CGFloat { get }
    var interItemSpacing: CGFloat { get }
    var children: [any Component] { get }
}

extension WaterfallLayoutProtocol {
    public func layout(_ constraint: Constraint) -> R {
        var renderNodes: [any RenderNode] = []
        var positions: [CGPoint] = []

        let columnWidth = (cross(constraint.maxSize) - CGFloat(columns - 1) * columnSpacing) / CGFloat(columns)
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
            columnHeight[columnIndex] += main(renderNode.size) + interItemSpacing
            renderNodes.append(renderNode)
            positions.append(point(main: offsetY, cross: CGFloat(columnIndex) * (columnWidth + columnSpacing)))
        }

        return renderNode(
            size: size(main: max(0, columnHeight.max()! - interItemSpacing), cross: cross(constraint.maxSize)),
            children: renderNodes,
            positions: positions
        )
    }
}

/// A `Waterfall` represents a vertical waterfall layout, which arranges items in multiple columns with varying item heights, similar to a masonry layout.
public struct Waterfall: Component, WaterfallLayoutProtocol, VerticalLayoutProtocol {
    /// The number of columns in the layout.
    public var columns: Int
    /// The spacing between columns in the layout.
    public var columnSpacing: CGFloat
    /// The spacing between items within each column.
    public var interItemSpacing: CGFloat
    /// The spacing between columns and items in the layout.
    public var spacing: CGFloat {
        get {
            interItemSpacing
        }
        set {
            columnSpacing = newValue
            interItemSpacing = newValue
        }
    }
    /// The components that will be laid out according to the waterfall layout.
    public var children: [any Component]

    /// Initializes a new `Waterfall` layout with the specified number of columns, spacing, and child components.
    /// - Parameters:
    ///   - columns: The number of columns in the layout. Defaults to 2.
    ///   - columnSpacing: The spacing between columns in the layout. Defaults to 0.
    ///   - interItemSpacing: The spacing between items within each column. Defaults to 0.
    ///   - children: The components that will be laid out according to the waterfall layout. Defaults to an empty array.
    public init(columns: Int = 2, columnSpacing: CGFloat = 0, interItemSpacing: CGFloat = 0, children: [any Component] = []) {
        self.columns = columns
        self.columnSpacing = columnSpacing
        self.interItemSpacing = interItemSpacing
        self.children = children
    }

    /// Initializes a new `Waterfall` layout with equal spacing between columns and items.
    /// - Parameters:
    ///   - columns: The number of columns in the layout. Defaults to 2.
    ///   - spacing: The spacing between columns and items in the layout.
    ///   - children: The components that will be laid out according to the waterfall layout. Defaults to an empty array.
    public init(columns: Int = 2, spacing: CGFloat, children: [any Component] = []) {
        self.init(columns: columns, columnSpacing: spacing, interItemSpacing: spacing, children: children)
    }
}

/// A `HorizontalWaterfall` represents a horizontal waterfall layout, which arranges items in multiple rows with varying item widths, similar to a masonry layout in a horizontal orientation.
public struct HorizontalWaterfall: Component, WaterfallLayoutProtocol, HorizontalLayoutProtocol {
    /// The number of rows in the layout.
    public var columns: Int
    /// The spacing between rows in the layout.
    public var columnSpacing: CGFloat
    /// The spacing between items within each row.
    public var interItemSpacing: CGFloat
    /// The spacing between rows and items in the layout.
    public var spacing: CGFloat {
        get {
            interItemSpacing
        }
        set {
            columnSpacing = newValue
            interItemSpacing = newValue
        }
    }
    /// The components that will be laid out according to the horizontal waterfall layout.
    public var children: [any Component]
    /// Initializes a new `HorizontalWaterfall` layout with the specified number of rows, spacing, and child components.
    /// - Parameters:
    ///   - columns: The number of rows in the layout. Defaults to 2.
    ///   - columnSpacing: The spacing between rows in the layout. Defaults to 0.
    ///   - interItemSpacing: The spacing between items within each row. Defaults to 0.
    ///   - children: The components that will be laid out according to the horizontal waterfall layout. Defaults to an empty array.
    public init(columns: Int = 2, columnSpacing: CGFloat = 0, interItemSpacing: CGFloat = 0, children: [any Component] = []) {
        self.columns = columns
        self.columnSpacing = columnSpacing
        self.interItemSpacing = interItemSpacing
        self.children = children
    }

    /// Initializes a new `HorizontalWaterfall` layout with equal spacing between rows and items.
    /// - Parameters:
    ///   - columns: The number of rows in the layout. Defaults to 2.
    ///   - spacing: The spacing between rows and items in the layout.
    ///   - children: The components that will be laid out according to the horizontal waterfall layout. Defaults to an empty array.
    public init(columns: Int = 2, spacing: CGFloat, children: [any Component] = []) {
        self.init(columns: columns, columnSpacing: spacing, interItemSpacing: spacing, children: children)
    }
}

extension Waterfall {
    /// Initializes a new ``Waterfall`` layout with the specified number of columns, spacing, and child components.
    /// This initializer allows for a trailing closure syntax to define the child components using a ``ComponentArrayBuilder``.
    /// - Parameters:
    ///   - columns: The number of columns in the layout. Defaults to 2.
    ///   - columnSpacing: The spacing between columns in the layout. Defaults to 0.
    ///   - interItemSpacing: The spacing between items within each column. Defaults to 0.
    ///   - content: A result builder closure that returns an array of components to be laid out in the waterfall layout.
    public init(columns: Int = 2, columnSpacing: CGFloat = 0, interItemSpacing: CGFloat = 0, @ComponentArrayBuilder _ content: () -> [any Component]) {
        self.init(columns: columns, columnSpacing: columnSpacing, interItemSpacing: interItemSpacing, children: content())
    }

    /// Initializes a new ``Waterfall`` layout with equal spacing between columns and items using a result builder.
    /// - Parameters:
    ///   - columns: The number of columns in the layout. Defaults to 2.
    ///   - spacing: The spacing between columns and items in the layout.
    ///   - content: A result builder closure that returns an array of components to be laid out in the waterfall layout.
    public init(columns: Int = 2, spacing: CGFloat, @ComponentArrayBuilder _ content: () -> [any Component]) {
        self.init(columns: columns, spacing: spacing, children: content())
    }
}

extension HorizontalWaterfall {
    /// Initializes a new ``HorizontalWaterfall`` layout with the specified number of rows, spacing, and child components using a result builder.
    /// This initializer allows for a trailing closure syntax to define the child components using a ``ComponentArrayBuilder``.
    /// - Parameters:
    ///   - columns: The number of rows in the layout. Defaults to 2.
    ///   - columnSpacing: The spacing between rows in the layout. Defaults to 0.
    ///   - interItemSpacing: The spacing between items within each row. Defaults to 0.
    ///   - content: A result builder closure that returns an array of components to be laid out in the horizontal waterfall layout.
    public init(columns: Int = 2, columnSpacing: CGFloat = 0, interItemSpacing: CGFloat = 0, @ComponentArrayBuilder _ content: () -> [any Component]) {
        self.init(columns: columns, columnSpacing: columnSpacing, interItemSpacing: interItemSpacing, children: content())
    }

    /// Initializes a new ``HorizontalWaterfall`` layout with equal spacing between rows and items using a result builder.
    /// - Parameters:
    ///   - columns: The number of rows in the layout. Defaults to 2.
    ///   - spacing: The spacing between rows and items in the layout.
    ///   - content: A result builder closure that returns an array of components to be laid out in the horizontal waterfall layout.
    public init(columns: Int = 2, spacing: CGFloat, @ComponentArrayBuilder _ content: () -> [any Component]) {
        self.init(columns: columns, spacing: spacing, children: content())
    }
}
