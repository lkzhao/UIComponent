//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct VisibleFrameInsets: Component {
  let insets: UIEdgeInsets
  let child: Component
  
  public init(insets: UIEdgeInsets, child: Component) {
    self.insets = insets
    self.child = child
  }
  
  public func layout(_ constraint: Constraint) -> RenderNode {
    VisibleFrameInsetRenderNode(insets: insets, child: child.layout(constraint))
  }
}

public struct DynamicVisibleFrameInset: Component {
  let insetProvider: (CGRect) -> UIEdgeInsets
  let child: Component
  
  public init(insetProvider: @escaping (CGRect) -> UIEdgeInsets, child: Component) {
    self.insetProvider = insetProvider
    self.child = child
  }

  public func layout(_ constraint: Constraint) -> RenderNode {
    DynamicVisibleFrameInsetRenderNode(insetProvider: insetProvider, child: child.layout(constraint))
  }
}

struct VisibleFrameInsetRenderNode: RenderNode {
  let insets: UIEdgeInsets
  let child: RenderNode
  var size: CGSize {
    child.size
  }
  var children: [RenderNode] {
    [child]
  }
  var positions: [CGPoint] {
    [.zero]
  }
  func views(in frame: CGRect) -> [Renderable] {
    child.views(in: frame.inset(by: insets))
  }
}

struct DynamicVisibleFrameInsetRenderNode: RenderNode {
  let insetProvider: (CGRect) -> UIEdgeInsets
  let child: RenderNode
  var size: CGSize {
    child.size
  }
  var children: [RenderNode] {
    [child]
  }
  var positions: [CGPoint] {
    [.zero]
  }
  func views(in frame: CGRect) -> [Renderable] {
    child.views(in: frame.inset(by: insetProvider(frame)))
  }
}
