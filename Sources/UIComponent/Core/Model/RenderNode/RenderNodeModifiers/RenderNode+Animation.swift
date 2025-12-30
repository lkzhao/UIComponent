/// A render node that wraps content and provides custom animations for insert, update, and delete operations.
#if canImport(UIKit)
public struct AnimatorWrapperRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    var passthroughUpdate: Bool
    var insertBlock: ((UIView, UIView, CGRect) -> Void)?
    var updateBlock: ((UIView, UIView, CGRect) -> Void)?
    var deleteBlock: ((UIView, UIView, @escaping () -> Void) -> Void)?

    public func contextValue(_ key: RenderNodeContextKey) -> Any? {
        if key == .animator {
            var wrapper = WrapperAnimator()
            wrapper.content = content.animator
            wrapper.passthroughUpdate = passthroughUpdate
            wrapper.insertBlock = insertBlock
            wrapper.deleteBlock = deleteBlock
            wrapper.updateBlock = updateBlock
            return wrapper
        }
        return nil
    }
}

extension RenderNode {
    /// Applies an update animation to the render node.
    /// - Parameters:
    ///   - passthrough: A Boolean value that determines whether the update should be passed through to the next animator.
    ///   - updateBlock: A closure that defines the animation for updating the view.
    /// - Returns: An `AnimatorWrapperRenderNode` configured with the update animation.
    func animateUpdate(passthrough: Bool = false, _ updateBlock: @escaping ((UIView, UIView, CGRect) -> Void)) -> AnimatorWrapperRenderNode<Self> {
        AnimatorWrapperRenderNode(content: self, passthroughUpdate: passthrough, updateBlock: updateBlock)
    }

    /// Applies an insert animation to the render node.
    /// - Parameter insertBlock: A closure that defines the animation for inserting the view.
    /// - Returns: An `AnimatorWrapperRenderNode` configured with the insert animation.
    func animateInsert(_ insertBlock: @escaping (UIView, UIView, CGRect) -> Void) -> AnimatorWrapperRenderNode<Self> {
        AnimatorWrapperRenderNode(content: self, passthroughUpdate: false, insertBlock: insertBlock)
    }

    /// Applies a delete animation to the render node.
    /// - Parameter deleteBlock: A closure that defines the animation for deleting the view.
    /// - Returns: An `AnimatorWrapperRenderNode` configured with the delete animation.
    func animateDelete(_ deleteBlock: @escaping (UIView, UIView, @escaping () -> Void) -> Void) -> AnimatorWrapperRenderNode<Self> {
        AnimatorWrapperRenderNode(content: self, passthroughUpdate: false, deleteBlock: deleteBlock)
    }
}
#endif
