//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct Insets: Component {
  let insets: UIEdgeInsets
  let child: Component
  public init(insets: UIEdgeInsets, child: Component) {
    self.insets = insets
    self.child = child
  }
  public func layout(_ constraint: Constraint) -> RenderNode {
    InsetsRenderNode(child: child.layout(constraint.inset(by: insets)), insets: insets)
  }
}

public struct DynamicInsets: Component {
  let insetProvider: (Constraint) -> UIEdgeInsets
  let child: Component
  public init(insetProvider: @escaping (Constraint) -> UIEdgeInsets, child: Component) {
    self.insetProvider = insetProvider
    self.child = child
  }
  public func layout(_ constraint: Constraint) -> RenderNode {
    let insets = insetProvider(constraint)
    return InsetsRenderNode(child: child.layout(constraint.inset(by: insets)), insets: insets)
  }
}

struct InsetsRenderNode: RenderNode {
  let child: RenderNode
  let insets: UIEdgeInsets
  var size: CGSize {
    return child.size.inset(by: -insets)
  }
  var children: [RenderNode] {
    [child]
  }
  var positions: [CGPoint] {
    [CGPoint(x: insets.left, y: insets.top)]
  }
  func views(in frame: CGRect) -> [Renderable] {
    child.views(in: frame.offsetBy(dx: -insets.left, dy: -insets.top)).map {
      Renderable(id: $0.id,
                 keyPath: "inset." + $0.keyPath,
                 animator: $0.animator, renderNode: $0.renderNode, frame: $0.frame + CGPoint(x: insets.left, y: insets.top))
    }
  }
}
