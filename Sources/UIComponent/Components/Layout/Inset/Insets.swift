//  Created by Luke Zhao on 8/23/20.

import UIKit
import BaseToolbox

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
    child.size.inset(by: -insets)
  }
  var children: [RenderNode] {
    [child]
  }
  var positions: [CGPoint] {
    [CGPoint(x: insets.left, y: insets.top)]
  }
}
