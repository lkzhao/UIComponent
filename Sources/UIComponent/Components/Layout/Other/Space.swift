//  Created by Luke Zhao on 8/23/20.

import UIKit

/// A component that represents a space with a specific size.
public struct Space: Component {
    /// The size of the space.
    let size: CGSize
    
    /// Initializes a new space with the given size.
    /// - Parameter size: The `CGSize` representing the width and height of the space.
    public init(size: CGSize) {
        self.size = size
    }
    
    /// Initializes a new space with the given width and height.
    /// - Parameters:
    ///   - width: The width of the space, default is 0.
    ///   - height: The height of the space, default is 0.
    public init(width: CGFloat = 0, height: CGFloat = 0) {
        size = CGSize(width: width, height: height)
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        SpaceRenderNode(size: size.bound(to: constraint))
    }
}

/// A render node that represents a space in the UI.
public struct SpaceRenderNode: RenderNode {
    /// The view type that this render node represents.
    public typealias View = UIView

    /// The size of the space.
    public let size: CGSize

    public init(size: CGSize) {
        self.size = size
    }

    public var shouldRenderView: Bool {
        false
    }
}
