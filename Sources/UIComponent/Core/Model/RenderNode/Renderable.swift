//  Created by Luke Zhao on 8/22/20.

import UIKit
@_implementationOnly import BaseToolbox

public protocol Renderable {
    var id: String { get }
    var userDefinedId: String? { get }
    var animator: Animator? { get }
    var renderNode: any RenderNode { get }
    var frame: CGRect { get }
}

public struct ViewRenderable: Renderable {
    public let renderNode: any RenderNode
    public init(renderNode: any RenderNode) {
        self.renderNode = renderNode
    }
    public var userDefinedId: String? {
        renderNode.id
    }
    public var id: String {
        userDefinedId ?? renderNode.keyPath
    }
    public var animator: Animator? {
        renderNode.animator
    }
    public var frame: CGRect {
        CGRect(origin: .zero, size: renderNode.size)
    }
}

public struct OffsetRenderable: Renderable {
    public let renderable: Renderable
    public let offset: CGPoint
    public let index: Int
    public init(renderable: Renderable, offset: CGPoint, index: Int) {
        self.renderable = renderable
        self.offset = offset
        self.index = index
    }
    public var userDefinedId: String? {
        renderable.userDefinedId
    }
    public var id: String {
        renderable.userDefinedId ?? "\(type(of: self))-\(index).\(renderable.id)"
    }
    public var animator: Animator? {
        renderable.animator
    }
    public var renderNode: any RenderNode {
        renderable.renderNode
    }
    public var frame: CGRect {
        renderable.frame + offset
    }
}

public struct IdOverrideRenderable: Renderable {
    public var id: String
    public var renderable: Renderable
    public init(id: String, renderable: Renderable) {
        self.id = id
        self.renderable = renderable
    }
    public var userDefinedId: String? {
        renderable.userDefinedId
    }
    public var animator: Animator? {
        renderable.animator
    }
    public var renderNode: any RenderNode {
        renderable.renderNode
    }
    public var frame: CGRect {
        renderable.frame
    }
}
