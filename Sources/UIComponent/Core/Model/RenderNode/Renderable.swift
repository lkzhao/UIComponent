//  Created by Luke Zhao on 8/22/20.

import UIKit

public struct Renderable {
    public var id: String?
    public var keyPath: String
    public var animator: Animator?
    public var renderNode: AnyViewRenderNode
    public var frame: CGRect
    public init(id: String?, keyPath: String, animator: Animator?, renderNode: AnyViewRenderNode, frame: CGRect) {
        self.id = id
        self.keyPath = keyPath
        self.animator = animator
        self.renderNode = renderNode
        self.frame = frame
    }
}
