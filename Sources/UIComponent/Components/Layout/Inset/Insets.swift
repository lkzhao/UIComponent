//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct Insets: Component {
  let insets: UIEdgeInsets
  let child: Component
  public init(insets: UIEdgeInsets, child: Component) {
    self.insets = insets
    self.child = child
  }
  public func layout(_ constraint: Constraint) -> Renderer {
    InsetsRenderer(child: child.layout(constraint.inset(by: insets)), insets: insets)
  }
}

public struct DynamicInsets: Component {
  let insetProvider: (Constraint) -> UIEdgeInsets
  let child: Component
  public init(insetProvider: @escaping (Constraint) -> UIEdgeInsets, child: Component) {
    self.insetProvider = insetProvider
    self.child = child
  }
  public func layout(_ constraint: Constraint) -> Renderer {
    let insets = insetProvider(constraint)
    return InsetsRenderer(child: child.layout(constraint.inset(by: insets)), insets: insets)
  }
}

struct InsetsRenderer: Renderer {
  let child: Renderer
  let insets: UIEdgeInsets
  var size: CGSize {
    return child.size.inset(by: -insets)
  }
  var children: [Renderer] {
    [child]
  }
  var positions: [CGPoint] {
    [CGPoint(x: insets.left, y: insets.top)]
  }
  func views(in frame: CGRect) -> [Renderable] {
    child.views(in: frame.inset(by: -insets)).map {
      Renderable(id: $0.id,
                 keyPath: "inset." + $0.keyPath,
                 animator: $0.animator, renderer: $0.renderer, frame: $0.frame + CGPoint(x: insets.left, y: insets.top))
    }
  }
}

public extension Component {
  func inset(_ amount: CGFloat) -> Component {
    Insets(insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount), child: self)
  }
  func inset(h: CGFloat = 0, v: CGFloat = 0) -> Component {
    Insets(insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h), child: self)
  }
  func inset(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Component {
    Insets(insets: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right), child: self)
  }
  func inset(by insets: UIEdgeInsets) -> Component {
    Insets(insets: insets, child: self)
  }
  func inset(_ insetProvider: @escaping (Constraint) -> UIEdgeInsets) -> Component {
    DynamicInsets(insetProvider: insetProvider, child: self)
  }
}
