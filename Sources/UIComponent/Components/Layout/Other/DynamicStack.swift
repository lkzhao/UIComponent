//  Created by Luke Zhao on 5/4/24.

/// A component that lays out its children horizontally in a paging fashion similar to an ``HStack``.
/// However, instead of creating the child components all at once, it creates them on demand when it needs to render the specific cell.
public struct DynamicHStack: Component {
    /// The total number of cells.
    public let count: Int
    /// The width of each cell.
    public let cellWidth: CGFloat
    /// The spacing between each cell.
    public let spacing: CGFloat
    /// Defines how child components are aligned along the cross axis.
    public let alignItems: CrossAxisAlignment
    /// The content provider that returns a component for a given cell index.
    public let content: (Int) -> any Component

    /// Initializes a new `DynamicHStack` with the specified number of cells and content provider.
    /// - Parameters:
    ///   - count: The total number of cells.
    ///   - cellWidth: The width of each cell.
    ///   - spacing: The spacing between each cell. Default: 0.
    ///   - content: A closure that provides the content for a given cell index.
    public init(count: Int, cellWidth: CGFloat, spacing: CGFloat = 0, alignItems: CrossAxisAlignment = .start, content: @escaping (Int) -> any Component) {
        self.count = count
        self.cellWidth = cellWidth
        self.spacing = spacing
        self.alignItems = alignItems
        self.content = content
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        DynamicHStackRenderNode(count: count,
                                constraintSize: CGSize(width: cellWidth, height: constraint.maxSize.height),
                                spacing: spacing,
                                alignItems: alignItems,
                                content: content)
    }
}

/// A component that lays out its children vertically in a paging fashion similar to an ``VStack``.
/// However, instead of creating the child components all at once, it creates them on demand when it needs to render the specific cell.
public struct DynamicVStack: Component {
    /// The total number of cells.
    public let count: Int
    /// The height of each cell.
    public let cellHeight: CGFloat
    /// The spacing between each cell.
    public let spacing: CGFloat
    /// Defines how child components are aligned along the cross axis.
    public let alignItems: CrossAxisAlignment
    /// The content provider that returns a component for a given cell index.
    public let content: (Int) -> any Component

    /// Initializes a new `DynamicVStack` with the specified number of cells and content provider.
    /// - Parameters:
    ///   - count: The total number of cells.
    ///   - cellHeight: The height of each cell.
    ///   - spacing: The spacing between each cell. Default: 0.
    ///   - content: A closure that provides the content for a given cell index.
    public init(count: Int, cellHeight: CGFloat, spacing: CGFloat = 0, alignItems: CrossAxisAlignment = .start, content: @escaping (Int) -> any Component) {
        self.count = count
        self.cellHeight = cellHeight
        self.spacing = spacing
        self.alignItems = alignItems
        self.content = content
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        DynamicVStackRenderNode(count: count,
                                constraintSize: CGSize(width: constraint.maxSize.width, height: cellHeight),
                                spacing: spacing,
                                alignItems: alignItems,
                                content: content)
    }
}

public struct DynamicVStackRenderNode: DynamicStackRenderNode, VerticalLayoutProtocol {
    public typealias View = UIView

    public let count: Int
    public let constraintSize: CGSize
    public let spacing: CGFloat
    public let alignItems: CrossAxisAlignment
    public let content: (Int) -> any Component
}

public struct DynamicHStackRenderNode: DynamicStackRenderNode, HorizontalLayoutProtocol {
    public typealias View = UIView

    public let count: Int
    public let constraintSize: CGSize
    public let spacing: CGFloat
    public let alignItems: CrossAxisAlignment
    public let content: (Int) -> any Component
}

/// A protocol that defines the properties and behaviors of a dynamic stack component.
public protocol DynamicStackRenderNode: RenderNode, BaseLayoutProtocol {
    /// Defines how child components are aligned along the cross axis.
    var alignItems: CrossAxisAlignment { get }
    var count: Int { get }
    var constraintSize: CGSize { get }
    var spacing: CGFloat { get }
    var content: (Int) -> any Component { get }
    var size: CGSize { get }
    func visibleChildren(in frame: CGRect) -> [RenderNodeChild]
}

extension DynamicStackRenderNode {
    public var size: CGSize {
        size(main: main(constraintSize) * CGFloat(count) + spacing * CGFloat(count - 1), cross: cross(constraintSize))
    }

    public func visibleChildren(in frame: CGRect) -> [RenderNodeChild] {
        let mainSize = main(constraintSize) + spacing
        let crossSize = cross(constraintSize)
        let start = Int(main(frame.origin) / mainSize)
        let end = Int((main(CGPoint(x: frame.maxX, y: frame.maxY)) - 0.1) / mainSize)
        let indexes = start...end
        let childConstraint = Constraint(minSize: size(main: main(constraintSize), cross: alignItems == .stretch ? cross(constraintSize) : -.infinity), maxSize: constraintSize)
        return indexes.map { i in
            let child = content(i).layout(childConstraint)
            var crossValue: CGFloat = 0
            switch alignItems {
            case .start, .stretch, .baselineFirst:
                crossValue = 0
            case .end, .baselineLast:
                crossValue = crossSize - cross(child.size)
            case .center:
                crossValue = (crossSize - cross(child.size)) / 2
            }
            let position = point(main: CGFloat(i) * mainSize, cross: crossValue)
            return RenderNodeChild(renderNode: child, position: position, index: i)
        }
    }
}
