//  Created by Luke Zhao on 8/24/20.

import UIKit

/// A `Separator` is a `ComponentBuilder` that creates a visual divider based on the specified color.
/// The separator can be either horizontal or vertical depending on the given constraints.
public struct Separator: ComponentBuilder {
    /// The default color of the separator.
    public static var defaultSeparatorColor: UIColor = UIColor.separator

    /// The color of the separator.
    public let color: UIColor

    /// Initializes a new separator with the specified color.
    /// - Parameter color: The color of the separator. If not specified, the default separator color is used.
    public init(color: UIColor = Separator.defaultSeparatorColor) {
        self.color = color
    }

    /// Builds the separator component
    ///
    /// * Will return a horizontal separator when put in an infinite height parent (e.g. VStack).
    /// * Will return a vertical separator when put in an infinite width parent (e.g. HStack).
    ///
    /// - Returns: A component representing the separator.
    public func build() -> some Component {
        ViewComponent<UIView>().backgroundColor(color)
            .constraint { constraint in
                if constraint.minSize.height <= 0, constraint.maxSize.width != .infinity {
                    let size = CGSize(width: constraint.maxSize.width, height: 1 / UIScreen.main.scale)
                    return Constraint(minSize: size, maxSize: size)
                } else if constraint.minSize.width <= 0, constraint.maxSize.height != .infinity {
                    let size = CGSize(width: 1 / UIScreen.main.scale, height: constraint.maxSize.height)
                    return Constraint(minSize: size, maxSize: size)
                }
                return constraint
            }
    }
}
