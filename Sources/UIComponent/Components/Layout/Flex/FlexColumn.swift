//  Created by Luke Zhao on 7/18/21.

import UIKit

/// # FlexColumn Component
///
/// Renders a list of child components using `flex-column` layout.
///
/// ```
/// [1] [4]
/// [2] [5]
/// [3]
/// ```
///
/// Example:
/// ```swift
/// FlexColumn(spacing: 10, justifyContent: .start, alignItems: .center) {
///   for cellData in cells {
///      Cell(data: cellData)
///   }
/// }
/// ```
///
/// Checkout the `FlexLayoutViewController.swift` for other examples.
public struct FlexColumn: FlexLayout, HorizontalLayoutProtocol {
    public var lineSpacing: CGFloat
    public var interitemSpacing: CGFloat

    public var alignContent: MainAxisAlignment
    public var alignItems: CrossAxisAlignment
    public var justifyContent: MainAxisAlignment
    public var tailJustifyContent: MainAxisAlignment?
    public var children: [Component]

    public init(
        lineSpacing: CGFloat = 0,
        interitemSpacing: CGFloat = 0,
        justifyContent: MainAxisAlignment = .start,
        alignItems: CrossAxisAlignment = .start,
        alignContent: MainAxisAlignment = .start,
        children: [Component]
    ) {
        self.lineSpacing = lineSpacing
        self.interitemSpacing = interitemSpacing
        self.justifyContent = justifyContent
        self.alignItems = alignItems
        self.alignContent = alignContent
        self.children = children
    }
}
