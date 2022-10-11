//  Created by Luke Zhao on 8/25/20.

import UIKit

/// Read incoming constraint and pass it to a Component `builder` block
///
/// e.g Normally the following will fail because we are trying to fill an infinite x axis
///
///     HStack {
///       Space(height: 50).size(width: .fill)
///     }
///
/// We can solve this issue by reading the top level constraint and pass it into the child so it doesn't get an infinite width
///
///     ConstraintReaderComponent { constraint in
///       HStack {
///         Space(width: 50, height: 50).size(width: .fill).constraint(constraint)
///       }
///     }
public struct ConstraintReader: Component {
    let builder: (Constraint) -> Component

    public init(_ builder: @escaping (Constraint) -> Component) {
        self.builder = builder
    }

    public func layout(_ constraint: Constraint) -> RenderNode {
        builder(constraint).layout(constraint)
    }
}
