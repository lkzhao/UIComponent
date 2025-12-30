//  Created by Luke Zhao on 7/18/21.

/// Flow layout component, similar to ``UICollectionViewFlowLayout``. It is type aliased to ``FlexRow``
public typealias Flow = FlexRow

/// A `FlexRow` structures its children in a horizontal row using flexbox properties. Once the row is filled, it will wrap to the next row.
///
/// ```
/// [1] [2] [3]
/// [4] [5]
/// ```
///
/// Example:
/// ```swift
/// FlexRow(spacing: 10, justifyContent: .start, alignItems: .center) {
///   for cellData in cells {
///      Cell(data: cellData)
///   }
/// }
/// ```
///
/// You can use in conjunction with ``Component/flex(flexGrow:flexShrink:alignSelf:)`` modifier on its child to adjust the child's flex properties.
///
/// Checkout the ``FlexLayoutViewController`` for other examples.
public struct FlexRow: Component, FlexLayout, VerticalLayoutProtocol {
    /// The spacing between lines in the flex layout.
    public var lineSpacing: CGFloat
    /// The spacing between items within a line.
    public var interitemSpacing: CGFloat

    /// The alignment strategy for lines when there is extra space in the cross-axis.
    public var alignContent: MainAxisAlignment
    /// The alignment strategy for items within the cross-axis of each line.
    public var alignItems: CrossAxisAlignment
    /// The distribution strategy for items within the main-axis.
    public var justifyContent: MainAxisAlignment
    /// The array of child components to layout within the flex row.
    public var children: [any Component]

    /// Creates a new instance of a `FlexRow`.
    ///
    /// - Parameters:
    ///   - lineSpacing: The spacing between lines in the flex layout.
    ///   - interitemSpacing: The spacing between items within a line.
    ///   - justifyContent: The distribution strategy for items within the main-axis.
    ///   - alignItems: The alignment strategy for items within the cross-axis of each line.
    ///   - alignContent: The alignment strategy for lines when there is extra space in the cross-axis.
    ///   - children: The array of child components to layout within the flex row.
    public init(
        lineSpacing: CGFloat = 0,
        interitemSpacing: CGFloat = 0,
        justifyContent: MainAxisAlignment = .start,
        alignItems: CrossAxisAlignment = .start,
        alignContent: MainAxisAlignment = .start,
        children: [any Component]
    ) {
        self.lineSpacing = lineSpacing
        self.interitemSpacing = interitemSpacing
        self.justifyContent = justifyContent
        self.alignItems = alignItems
        self.alignContent = alignContent
        self.children = children
    }
}
