//  Created by Luke Zhao on 8/23/20.

/// A component that applies fixed insets to the visible frame of its child component.
///
/// If the insets is negative, the child component will be rendered outside of the visible frame.
/// If the insets is positive, the child component might not appear since it might think it is outside of the visible frame.
///
/// One use case is to assign a negative visible inset, to preload views on screen.
public struct VisibleFrameInsets<Content: Component>: Component {
    /// The content component that will be adjusted based on the fixed insets.
    public let content: Content

    /// The fixed insets to apply to the visible frame of the content.
    public let insets: UIEdgeInsets

    /// Initializes a new `VisibleFrameInsetRenderNode` with the given content and insets.
    /// - Parameters:
    ///   - content: The content render node to which the insets will be applied.
    ///   - insets: The fixed insets to apply to the visible frame.
    public init(content: Content, insets: UIEdgeInsets) {
        self.content = content
        self.insets = insets
    }

    public func layout(_ constraint: Constraint) -> VisibleFrameInsetRenderNode<Content.R> {
        VisibleFrameInsetRenderNode(content: content.layout(constraint), insets: insets)
    }
}

/// A component that applies dynamic insets to the visible frame of its child component.
/// The insets are determined at render time based on the provided frame.
///
/// If the insets is negative, the child component will be rendered outside of the visible frame.
/// If the insets is positive, the child component might not appear since it might think it is outside of the visible frame.
///
/// One use case is to assign a negative visible inset, to preload views on screen.
public struct DynamicVisibleFrameInset<Content: Component>: Component {
    /// The content component that will be adjusted based on the dynamic insets.
    public let content: Content

    /// A closure that provides dynamic insets based on the given frame, used to adjust the visible frame of the content.
    public let insetProvider: (CGRect) -> UIEdgeInsets

    /// Initializes a new `DynamicVisibleFrameInset` with the given content and inset provider.
    /// - Parameters:
    ///   - content: The content render node to which the dynamic insets will be applied.
    ///   - insetProvider: A closure that provides a `UIEdgeInsets` value based on the given `CGRect`.
    public init(content: Content, insetProvider: @escaping (CGRect) -> UIEdgeInsets) {
        self.content = content
        self.insetProvider = insetProvider
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        DynamicVisibleFrameInsetRenderNode(content: content.layout(constraint), insetProvider: insetProvider)
    }
}

/// A render node wrapper that applies fixed insets to the visible frame of its content.
public struct VisibleFrameInsetRenderNode<Content: RenderNode>: RenderNodeWrapper {

    /// The content render node that will be adjusted based on the fixed insets.
    public let content: Content

    /// The fixed insets to apply to the visible frame of the content.
    public let insets: UIEdgeInsets

    /// The ascender of the render node, adjusted for the top inset.
    public var ascender: CGFloat {
        content.ascender + insets.top
    }

    /// The descender of the render node, adjusted for the bottom inset.
    public var descender: CGFloat {
        content.descender - insets.bottom
    }

    /// Initializes a new `VisibleFrameInsetRenderNode` with the given content and insets.
    /// - Parameters:
    ///   - content: The content render node to which the insets will be applied.
    ///   - insets: The fixed insets to apply to the visible frame.
    public init(content: Content, insets: UIEdgeInsets) {
        self.content = content
        self.insets = insets
    }

    public func adjustVisibleFrame(frame: CGRect) -> CGRect {
        frame.inset(by: insets)
    }
}

/// A render node wrapper that applies dynamic insets to the visible frame of its content.
/// The insets are determined at layout time based on the provided frame.
public struct DynamicVisibleFrameInsetRenderNode<Content: RenderNode>: RenderNodeWrapper {

    /// The content render node that will be adjusted based on the dynamic insets.
    public let content: Content

    /// A closure that provides dynamic insets based on the given frame, used to adjust the visible frame of the content.
    public let insetProvider: (CGRect) -> UIEdgeInsets

    /// Initializes a new `DynamicVisibleFrameInsetRenderNode` with the given content and inset provider.
    /// - Parameters:
    ///   - content: The content render node to which the dynamic insets will be applied.
    ///   - insetProvider: A closure that provides a `UIEdgeInsets` value based on the given `CGRect`.
    public init(content: Content, insetProvider: @escaping (CGRect) -> UIEdgeInsets) {
        self.content = content
        self.insetProvider = insetProvider
    }

    public func adjustVisibleFrame(frame: CGRect) -> CGRect {
        frame.inset(by: insetProvider(frame))
    }
}
