//  Created by Luke Zhao on 8/22/20.

import UIKit

/// A render node that store an update block to be applied to the view when the ComponentView reloads.
public struct UpdateRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let update: (Content.View) -> Void

    public var reuseStrategy: ReuseStrategy {
        // we don't know what the update block did, so we disable
        // reuse so that we don't get inconsistent state
        .noReuse
    }

    public func shouldRenderView(in frame: CGRect) -> Bool {
        frame.intersects(CGRect(origin: .zero, size: size))
    }

    public func updateView(_ view: Content.View) {
        content.updateView(view)
        update(view)
    }
}

/// A render node that applies a value to a specific key path of the view.
public struct KeyPathUpdateRenderNode<Value, Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let valueKeyPath: ReferenceWritableKeyPath<Content.View, Value>
    public let value: Value

    public func updateView(_ view: Content.View) {
        content.updateView(view)
        view[keyPath: valueKeyPath] = value
    }

    public func shouldRenderView(in frame: CGRect) -> Bool {
        frame.intersects(CGRect(origin: .zero, size: size))
    }
}

/// A render node that overrides an identifier to the content.
public struct IDRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let id: String?
}

/// A render node that overrides the animator of the content.
public struct AnimatorRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let animator: Animator?
}

/// A render node that overrides the reuse strategy of the content.
public struct ReuseStrategyRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let reuseStrategy: ReuseStrategy
}

extension RenderNode {
    /// Accesses a dynamic member using a key path to the view's properties.
    /// - Parameter keyPath: A key path to a specific property of the view.
    /// - Returns: A closure that takes a new value for the property and returns a `KeyPathUpdateRenderNode`.
    subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<View, Value>) -> (Value) -> KeyPathUpdateRenderNode<Value, Self> {
        { with(keyPath, $0) }
    }
    
    /// Creates a render node that updates a specific property of the view.
    /// - Parameters:
    ///   - keyPath: A key path to the specific property of the view to be updated.
    ///   - value: The new value to be set for the property.
    /// - Returns: A `KeyPathUpdateRenderNode` with the new value applied.
    public func with<Value>(_ keyPath: ReferenceWritableKeyPath<View, Value>, _ value: Value) -> KeyPathUpdateRenderNode<Value, Self> {
        KeyPathUpdateRenderNode(content: self, valueKeyPath: keyPath, value: value)
    }
    
    /// Creates a render node that overrides the identifier of the content.
    /// - Parameter id: An optional identifier to be set for the content.
    /// - Returns: An `IDRenderNode` with the overridden identifier.
    public func id(_ id: String?) -> IDRenderNode<Self> {
        IDRenderNode(content: self, id: id)
    }
    
    /// Creates a render node that overrides the animator of the content.
    /// - Parameter animator: An optional animator to be set for the content.
    /// - Returns: An `AnimatorRenderNode` with the overridden animator.
    public func animator(_ animator: Animator?) -> AnimatorRenderNode<Self> {
        AnimatorRenderNode(content: self, animator: animator)
    }
    
    /// Creates a render node that overrides the reuse strategy of the content.
    /// - Parameter reuseStrategy: The reuse strategy to be set for the content.
    /// - Returns: A `ReuseStrategyRenderNode` with the overridden reuse strategy.
    public func reuseStrategy(_ reuseStrategy: ReuseStrategy) -> ReuseStrategyRenderNode<Self> {
        ReuseStrategyRenderNode(content: self, reuseStrategy: reuseStrategy)
    }
    
    /// Creates a render node that applies a custom update to the view.
    /// - Parameter update: A closure that defines how the view should be updated.
    /// - Returns: An `UpdateRenderNode` that uses the custom update closure.
    public func update(_ update: @escaping (View) -> Void) -> UpdateRenderNode<Self> {
        UpdateRenderNode(content: self, update: update)
    }
}

/// A render node that wraps content and provides custom animations for insert, update, and delete operations.
public struct AnimatorWrapperRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    var passthroughUpdate: Bool
    var insertBlock: ((ComponentDisplayableView, UIView, CGRect) -> Void)?
    var updateBlock: ((ComponentDisplayableView, UIView, CGRect) -> Void)?
    var deleteBlock: ((ComponentDisplayableView, UIView, @escaping () -> Void) -> Void)?
    public var animator: Animator? {
        var wrapper = WrapperAnimator()
        wrapper.content = content.animator
        wrapper.passthroughUpdate = passthroughUpdate
        wrapper.insertBlock = insertBlock
        wrapper.deleteBlock = deleteBlock
        wrapper.updateBlock = updateBlock
        return wrapper
    }
}

extension RenderNode {
    /// Applies an update animation to the render node.
    /// - Parameters:
    ///   - passthrough: A Boolean value that determines whether the update should be passed through to the next animator.
    ///   - updateBlock: A closure that defines the animation for updating the view.
    /// - Returns: An `AnimatorWrapperRenderNode` configured with the update animation.
    func animateUpdate(passthrough: Bool = false, _ updateBlock: @escaping ((ComponentDisplayableView, UIView, CGRect) -> Void)) -> AnimatorWrapperRenderNode<Self> {
        AnimatorWrapperRenderNode(content: self, passthroughUpdate: passthrough, updateBlock: updateBlock)
    }
    
    /// Applies an insert animation to the render node.
    /// - Parameter insertBlock: A closure that defines the animation for inserting the view.
    /// - Returns: An `AnimatorWrapperRenderNode` configured with the insert animation.
    func animateInsert(_ insertBlock: @escaping (ComponentDisplayableView, UIView, CGRect) -> Void) -> AnimatorWrapperRenderNode<Self> {
        AnimatorWrapperRenderNode(content: self, passthroughUpdate: false, insertBlock: insertBlock)
    }
    
    /// Applies a delete animation to the render node.
    /// - Parameter deleteBlock: A closure that defines the animation for deleting the view.
    /// - Returns: An `AnimatorWrapperRenderNode` configured with the delete animation.
    func animateDelete(_ deleteBlock: @escaping (ComponentDisplayableView, UIView, @escaping () -> Void) -> Void) -> AnimatorWrapperRenderNode<Self> {
        AnimatorWrapperRenderNode(content: self, passthroughUpdate: false, deleteBlock: deleteBlock)
    }
}

extension RenderNode {
    /// Erases the type of the render node and wraps it in a type-erasing `AnyRenderNode`.
    /// - Returns: An `AnyRenderNode` instance.
    public func eraseToAnyRenderNode() -> AnyRenderNode {
        AnyRenderNode(self)
    }
    
    /// Erases the type of the render node that has a specific view type and wraps it in a type-erasing `AnyRenderNodeOfView`.
    /// - Returns: An `AnyRenderNodeOfView` instance that holds a type-erased render node of the specific view type.
    public func eraseToAnyRenderNodeOfView() -> AnyRenderNodeOfView<View> {
        AnyRenderNodeOfView(self)
    }
}
