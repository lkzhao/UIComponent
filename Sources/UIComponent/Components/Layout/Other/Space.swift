//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct Space: Component {
    let size: CGSize
    public init(size: CGSize) {
        self.size = size
    }
    public init(width: CGFloat = 0, height: CGFloat = 0) {
        size = CGSize(width: width, height: height)
    }
    public func layout(_ constraint: Constraint) -> AnyRenderNode {
        SpaceRenderNode(size: size.bound(to: constraint))
    }
}

struct SpaceRenderNode: ViewRenderNode {
    typealias View = NeverView
    let size: CGSize
}
