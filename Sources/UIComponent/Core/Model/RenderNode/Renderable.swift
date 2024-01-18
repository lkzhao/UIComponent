//  Created by Luke Zhao on 8/22/20.

import UIKit

/// A `Renderable` represents an object that can be rendered within a given frame.
/// It contains a reference to a `RenderNode` which dictates how the rendering should be done.
/// The `fallbackId` is used for identity purposes when there is no user-defined identifier.
public struct Renderable {
    /// The frame within which the `Renderable` should be drawn.
    public var frame: CGRect
    /// The rendering logic encapsulated within a `RenderNode`.
    public var renderNode: any RenderNode
    /// An identifier used for structural identity when there is no user-defined id.
    public var fallbackId: String

    /// Initializes a new `Renderable` with the specified frame, render node, and fallback identifier.
    /// - Parameters:
    ///   - frame: The frame within which the `Renderable` should be drawn.
    ///   - renderNode: The rendering logic encapsulated within a `RenderNode`.
    ///   - fallbackId: An identifier used for structural identity when there is no user-defined id.
    public init(frame: CGRect, renderNode: any RenderNode, fallbackId: String) {
        self.frame = frame
        self.renderNode = renderNode
        self.fallbackId = fallbackId
    }
}
