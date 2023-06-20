//  Created by Luke Zhao on 8/22/20.

import UIKit

public protocol RenderNodeWrapper: RenderNode {
    associatedtype Content: RenderNode
    var content: Content { get }
}

extension RenderNodeWrapper {
    public var id: String? {
        content.id
    }
    public var reuseStrategy: ReuseStrategy {
        content.reuseStrategy
    }
    public var animator: Animator? {
        content.animator
    }
    public var size: CGSize {
        content.size
    }
    public func updateView(_ view: Content.View) {
        content.updateView(view)
    }
    public func makeView() -> Content.View {
        content.makeView()
    }
}

public struct UpdateRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let update: (Content.View) -> Void

    public var reuseStrategy: ReuseStrategy {
        // we don't know what the update block did, so we disable
        // reuse so that we don't get inconsistent state
        .noReuse
    }

    public func updateView(_ view: Content.View) {
        content.updateView(view)
        update(view)
    }
}

public struct KeyPathUpdateRenderNode<Value, Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let valueKeyPath: ReferenceWritableKeyPath<Content.View, Value>
    public let value: Value

    public func updateView(_ view: Content.View) {
        content.updateView(view)
        view[keyPath: valueKeyPath] = value
    }
}

public struct IDRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let id: String?
}

public struct AnimatorRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let animator: Animator?
}

public struct ReuseStrategyRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let reuseStrategy: ReuseStrategy
}

extension RenderNode {
    subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<View, Value>) -> (Value) -> KeyPathUpdateRenderNode<Value, Self> {
        { with(keyPath, $0) }
    }
    public func with<Value>(_ keyPath: ReferenceWritableKeyPath<View, Value>, _ value: Value) -> KeyPathUpdateRenderNode<Value, Self> {
        KeyPathUpdateRenderNode(content: self, valueKeyPath: keyPath, value: value)
    }
    public func id(_ id: String?) -> IDRenderNode<Self> {
        IDRenderNode(content: self, id: id)
    }
    public func animator(_ animator: Animator?) -> AnimatorRenderNode<Self> {
        AnimatorRenderNode(content: self, animator: animator)
    }
    public func reuseStrategy(_ reuseStrategy: ReuseStrategy) -> ReuseStrategyRenderNode<Self> {
        ReuseStrategyRenderNode(content: self, reuseStrategy: reuseStrategy)
    }
    public func update(_ update: @escaping (View) -> Void) -> UpdateRenderNode<Self> {
        UpdateRenderNode(content: self, update: update)
    }
}

public struct AnimatorWrapperRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    var passthroughUpdate: Bool
    var insertBlock: ((ComponentDisplayableView, UIView, CGRect) -> Void)?
    var updateBlock: ((ComponentDisplayableView, UIView, CGRect) -> Void)?
    var deleteBlock: ((ComponentDisplayableView, UIView, () -> Void) -> Void)?
    public var animator: Animator? {
        let wrapper = WrapperAnimator()
        wrapper.content = content.animator
        wrapper.passthroughUpdate = passthroughUpdate
        wrapper.insertBlock = insertBlock
        wrapper.deleteBlock = deleteBlock
        wrapper.updateBlock = updateBlock
        return wrapper
    }
}

extension RenderNode {
    func animateUpdate(passthrough: Bool = false, _ updateBlock: @escaping ((ComponentDisplayableView, UIView, CGRect) -> Void)) -> AnimatorWrapperRenderNode<Self> {
        AnimatorWrapperRenderNode(content: self, passthroughUpdate: passthrough, updateBlock: updateBlock)
    }
}
