//  Created by Luke Zhao on 8/22/20.

import UIKit

/// A `Renderable` represents an object that can be rendered within a given frame.
/// It contains a reference to a `RenderNode` which dictates how the rendering should be done.
public struct Renderable {
    /// An identifier used for tracking the Renderable.
    public var id: String
    /// The frame within which the Renderable should be drawn.
    public var frame: CGRect
    /// The `RenderNode` responsible for making and updating the view represented by this Renderable
    public var renderNode: any RenderNode

    /// Initializes a new `Renderable` with the specified frame, render node, and fallback identifier.
    /// - Parameters:
    ///   - id: An identifier used for tracking the Renderable.
    ///   - frame: The frame within which the Renderable should be drawn.
    ///   - renderNode: The `RenderNode` responsible for making and updating the view represented by this Renderable
    public init(id: String, frame: CGRect, renderNode: any RenderNode) {
        self.id = id
        self.frame = frame
        self.renderNode = renderNode
    }
}
