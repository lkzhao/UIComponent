//  Created by Luke Zhao on 8/22/20.

import UIKit

public struct Renderable {
    public var frame: CGRect
    public var renderNode: any RenderNode

    // fallbackId is used when the renderable doesn't have a user defined id.
    // this is used for structure identity
    public var fallbackId: String

    public init(frame: CGRect, renderNode: any RenderNode, fallbackId: String) {
        self.frame = frame
        self.renderNode = renderNode
        self.fallbackId = fallbackId
    }
}
