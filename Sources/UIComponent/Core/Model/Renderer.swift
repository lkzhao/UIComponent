//  Created by Luke Zhao on 8/22/20.

import CoreGraphics

public protocol Renderer {
  /// size of the Renderer
  var size: CGSize { get }
  
  /// positions of child renderers
  var positions: [CGPoint] { get }
  
  /// child renderers
  var children: [Renderer] { get }
  
  /// Get items' view and its rect within the frame in current component's coordinates.
  /// - Parameter frame: Parent component's visible frame in current component's coordinates.
  func views(in frame: CGRect) -> [Renderable]
}

public extension Renderer {
  func frame(at index: Int) -> CGRect? {
    guard let size = children.get(index)?.size, let position = positions.get(index) else { return nil }
    return CGRect(origin: position, size: size)
  }
  
  func frame(id: String) -> CGRect? {
    if let viewRenderer = self as? AnyViewRenderer, viewRenderer.id == id {
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
