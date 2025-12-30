//  Created by Luke Zhao on 8/23/20.

/// `Join`  is used to interleave components with separators.
/// It can be used when building children of a layout component.
///
/// ```swift
/// VStack {
///     Join {
///         for item in items {
///             ItemComponent(item: item)
///         }
///     } separator: {
///         Space(height: 5)
///         Separator()
///         Space(height: 5)
///     }
/// }
/// // which will produce the following
/// VStack {
///     ItemComponent(item: item1)
///     Space(height: 5)
///     Separator()
///     Space(height: 5)
///     ItemComponent(item: item2)
///     Space(height: 5)
///     Separator()
///     Space(height: 5)
///     ItemComponent(item: item3)
///     ...
///     ItemComponent(item: itemN)
/// }
/// ```
///
/// > `Join` is not a Component, therefore it can only be used in a result builder
///  inside another layout component that takes in an array of children.
public struct Join: ComponentArrayContainer {
    /// The array of components that are combined with separators.
    public let components: [any Component]

    /// Initializes a `Join` struct with content and separator components.
    /// - Parameters:
    ///   - content: A closure that returns an array of components to be joined.
    ///   - separator: A closure that returns an array of components to be used as separators.
    public init(@ComponentArrayBuilder _ content: () -> [any Component], @ComponentArrayBuilder separator: () -> [any Component]) {
        var result: [any Component] = []
        let components = content()
        if !components.isEmpty {
            for i in 0..<components.count - 1 {
                result.append(components[i])
                result.append(contentsOf: separator())
            }
        }
        if let lastComponent = components.last {
            result.append(lastComponent)
        }
        self.components = result
    }
}
