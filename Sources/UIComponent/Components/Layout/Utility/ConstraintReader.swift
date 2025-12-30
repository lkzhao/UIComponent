//  Created by Luke Zhao on 8/25/20.

/// Read incoming constraint and pass it to a Component `builder` block. There are a few use cases.
///
/// ### Dynamic Layout Property
/// You can also use ConstraintReader to calculate dynamic layout properties based on the given constraint:
/// ```swift
/// ConstraintReader { constraint in
///     var preferredColumnWidth = 200.0
///     var columnCount = max(1, Int(constraint.maxSize.width / preferredColumnWidth))
///     // Dynamic # of columns based on the available width.
///     return Waterfall(columns: columnCount) {
///         // ...
///     }
/// }
/// ```
///
/// ### Pass down the constraint from outside into an infinite layout.
/// e.g. If you have a HStack, and wants each cell to be the same width of the screen.
/// Normally the following will fail because we are trying to fill an infinite x axis.
/// ```swift
/// HStack {
///   Space(height: 50).size(width: .fill)
/// }
/// ```
///
/// We can solve this issue by reading the top level constraint and pass it into the child so it doesn't get an infinite width
/// ```swift
/// ConstraintReaderComponent { constraint in
///   HStack {
///     Space(height: 50).size(width: .fill).constraint(constraint)
///   }
/// }
/// ```
///
public struct ConstraintReader: Component {
    let builder: (Constraint) -> any Component

    public init(_ builder: @escaping (Constraint) -> any Component) {
        self.builder = builder
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        builder(constraint).eraseToAnyComponent().layout(constraint)
    }
}
