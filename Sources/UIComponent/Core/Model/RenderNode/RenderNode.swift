//  Created by Luke Zhao on 8/22/20.

import CoreGraphics

public protocol RenderNode {
  /// size of the render node
  var size: CGSize { get }
  
  /// positions of child render nodes
  var positions: [CGPoint] { get }
  
  /// child render nodes
  var children: [RenderNode] { get }
  
  /// Get items' view and its rect within the frame in current component's coordinates.
  /// - Parameter frame: Parent component's visible frame in current component's coordinates.
  func views(in frame: CGRect) -> [Renderable]
}

public extension RenderNode {
  func frame(at index: Int) -> CGRect? {
    guard let size = children.get(index)?.size, let position = positions.get(index) else { return nil }
    return CGRect(origin: position, size: size)
  }
  
  func frame(id: String) -> CGRect? {
    if let viewRenderNode = self as? AnyViewRenderNode, viewRenderNode.id == id {
      return CGRect(origin: .zero, size: size)
    }
    for (index, child) in children.enumerated() {
      if let frame = child.frame(id: id) {
        return frame + positions[index]
      }
    }
    return nil
  }
}
