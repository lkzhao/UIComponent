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

struct ViewRenderable: Renderable {
    let renderNode: any RenderNode
    init(renderNode: any RenderNode) {
        self.renderNode = renderNode
    }
    var userDefinedId: String? {
        renderNode.id
    }
    var id: String {
        userDefinedId ?? "\(type(of: self))"
    }
    var animator: Animator? {
        renderNode.animator
    }
    var frame: CGRect {
        CGRect(origin: .zero, size: renderNode.size)
    }
}

struct OffsetRenderable: Renderable {
    let renderable: Renderable
    let offset: CGPoint
    let index: Int
    init(renderable: Renderable, offset: CGPoint, index: Int) {
        self.renderable = renderable
        self.offset = offset
        self.index = index
    }
    var userDefinedId: String? {
        renderable.userDefinedId
    }
    var id: String {
        renderable.userDefinedId ?? "\(type(of: self))-\(index).\(renderable.id)"
    }
    var animator: Animator? {
        renderable.animator
    }
    var renderNode: any RenderNode {
        renderable.renderNode
    }
    var frame: CGRect {
        renderable.frame + offset
    }
}

struct IdOverrideRenderable: Renderable {
    var id: String
    var renderable: Renderable
    init(id: String, renderable: Renderable) {
        self.id = id
        self.renderable = renderable
    }
    var userDefinedId: String? {
        renderable.userDefinedId
    }
    var animator: Animator? {
        renderable.animator
    }
    var renderNode: any RenderNode {
        renderable.renderNode
    }
    var frame: CGRect {
        renderable.frame
    }
}
