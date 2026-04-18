/// `ReverseIf` conditionally reverses components within a ``ComponentArrayBuilder``.
///
/// ```swift
/// VStack {
///     ReverseIf(isRightToLeft) {
///         Icon()
///         Text("Hello")
///     }
/// }
/// ```
public struct ReverseIf: ComponentArrayContainer {
    public var components: [any Component]

    public init(_ value: Bool, components: [any Component]) {
        self.components = value ? Array(components.reversed()) : components
    }

    public init(_ value: Bool, @ComponentArrayBuilder _ content: () -> [any Component]) {
        let components = content()
        self.components = value ? Array(components.reversed()) : components
    }
}
