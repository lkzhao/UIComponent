//  Created by Luke Zhao on 8/24/20.

#if os(macOS)
import AppKit
#endif

/// A `Separator` is a `ComponentBuilder` that creates a visual divider based on the specified color.
/// The separator can be either horizontal or vertical depending on the given constraints.
public struct Separator: ComponentBuilder {
    /// The default color of the separator.
    public static var defaultSeparatorColor: PlatformColor = PlatformColor.separator

    /// The color of the separator.
    public let color: PlatformColor

    /// Initializes a new separator with the specified color.
    /// - Parameter color: The color of the separator. If not specified, the default separator color is used.
    public init(color: PlatformColor = Separator.defaultSeparatorColor) {
        self.color = color
    }

    /// Builds the separator component
    ///
    /// * Will return a horizontal separator when put in an infinite height parent (e.g. VStack).
    /// * Will return a vertical separator when put in an infinite width parent (e.g. HStack).
    ///
    /// - Returns: A component representing the separator.
    public func build() -> some Component {
        ViewComponent<PlatformView>().backgroundColor(color)
            .constraint { constraint in
                if constraint.minSize.height <= 0, constraint.maxSize.width != .infinity {
                    let size = CGSize(width: constraint.maxSize.width, height: 1 / screenScale())
                    return Constraint(minSize: size, maxSize: size)
                } else if constraint.minSize.width <= 0, constraint.maxSize.height != .infinity {
                    let size = CGSize(width: 1 / screenScale(), height: constraint.maxSize.height)
                    return Constraint(minSize: size, maxSize: size)
                }
                return constraint
            }
    }
}

private func screenScale() -> CGFloat {
    #if os(visionOS)
    return 2.0
    #elseif os(macOS)
    return NSScreen.main?.backingScaleFactor ?? 2.0
    #else
    return UIScreen.main.scale
    #endif
}
