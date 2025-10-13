import UIKit

extension Component {
    /// Applies flexible layout properties to the component.
    /// This is used in conjunction with a flex container (FlexRow, FlexColumn, HStack, VStack).
    /// - Parameters:
    ///   - flex: The flex factor to be applied. Defaults to 1.
    ///   - alignSelf: The alignment of this component within a flex container. Defaults to nil.
    /// - Returns: A `ContextOverrideComponent` that wraps the current component with the specified layout properties.
    public func flex(_ flex: CGFloat = 1, alignSelf: CrossAxisAlignment? = nil) -> ContextOverrideComponent<Self> {
        var overrideContext = [RenderNodeContextKey: Any]()
        overrideContext[.flexGrow] = flex
        overrideContext[.flexShrink] = flex
        overrideContext[.alignSelf] = alignSelf
        return ContextOverrideComponent(content: self, overrideContext: overrideContext)
    }

    /// Applies flexible layout properties to the component with specified grow and shrink factors.
    /// This is used in conjunction with a flex container (FlexRow, FlexColumn, HStack, VStack).
    /// - Parameters:
    ///   - flexGrow: The flex grow factor.
    ///   - flexShrink: The flex shrink factor.
    ///   - alignSelf: The alignment of this component within a flex container. Defaults to nil.
    /// - Returns: A `ContextOverrideComponent` that wraps the current component with the specified layout properties.
    public func flex(flexGrow: CGFloat, flexShrink: CGFloat, alignSelf: CrossAxisAlignment? = nil) -> ContextOverrideComponent<Self> {
        var overrideContext = [RenderNodeContextKey: Any]()
        overrideContext[.flexGrow] = flexGrow
        overrideContext[.flexShrink] = flexShrink
        overrideContext[.alignSelf] = alignSelf
        return ContextOverrideComponent(content: self, overrideContext: overrideContext)
    }

    /// Applies flexible layout properties to the component with specified grow factors.
    /// This is used in conjunction with a flex container (FlexRow, FlexColumn, HStack, VStack).
    /// - Parameters:
    ///  - flexGrow: The flex grow factor.
    /// - Returns: A `ContextOverrideComponent` that wraps the current component with the specified layout properties.
    public func flexGrow(_ flexGrow: CGFloat) -> ContextOverrideComponent<Self> {
        var overrideContext = [RenderNodeContextKey: Any]()
        overrideContext[.flexGrow] = flexGrow
        return ContextOverrideComponent(content: self, overrideContext: overrideContext)
    }

    /// Applies flexible layout properties to the component with specified shrink factors.
    /// This is used in conjunction with a flex container (FlexRow, FlexColumn, HStack, VStack).
    /// - Parameters:
    ///  - flexShrink: The flex shrink factor.
    ///  - Returns: A `ContextOverrideComponent` that wraps the current component with the specified layout properties.
    public func flexShrink(_ flexShrink: CGFloat) -> ContextOverrideComponent<Self> {
        var overrideContext = [RenderNodeContextKey: Any]()
        overrideContext[.flexShrink] = flexShrink
        return ContextOverrideComponent(content: self, overrideContext: overrideContext)
    }

    /// Applies flexible layout properties to the component with specified alignment.
    /// This is used in conjunction with a flex container (FlexRow, FlexColumn, HStack, VStack).
    /// - Parameters:
    ///  - alignSelf: The alignment of this component within a flex container.
    ///  - Returns: A `ContextOverrideComponent` that wraps the current component with the specified layout properties.
    public func alignSelf(_ alignSelf: CrossAxisAlignment) -> ContextOverrideComponent<Self> {
        var overrideContext = [RenderNodeContextKey: Any]()
        overrideContext[.alignSelf] = alignSelf
        return ContextOverrideComponent(content: self, overrideContext: overrideContext)
    }
}
