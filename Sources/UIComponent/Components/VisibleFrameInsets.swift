//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

struct VisibleFrameInsets: Component {
  var insets: UIEdgeInsets
  let child: Component
  func layout(_ constraint: Constraint) -> Renderer {
    VisibleFrameInsetRenderer(insets: insets, child: child.layout(constraint))
  }
}

struct DynamicVisibleFrameInset: Component {
  let insetProvider: (CGRect) -> UIEdgeInsets
  let child: Component
  func layout(_ constraint: Constraint) -> Renderer {
    DynamicVisibleFrameInsetRenderer(insetProvider: insetProvider, child: child.layout(constraint))
  }
}

struct VisibleFrameInsetRenderer: Renderer {
  let insets: UIEdgeInsets
  let child: Renderer
  var size: CGSize {
    child.size
  }
  func views(in frame: CGRect) -> [Renderable] {
    child.views(in: frame.inset(by: insets))
  }
}

struct DynamicVisibleFrameInsetRenderer: Renderer {
  let insetProvider: (CGRect) -> UIEdgeInsets
  let child: Renderer
  var size: CGSize {
    child.size
  }
  func views(in frame: CGRect) -> [Renderable] {
    child.views(in: frame.inset(by: insetProvider(frame)))
  }
}

public extension Component {
  func visibleInset(_ amount: CGFloat) -> Component {
    VisibleFrameInsets(insets: UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount), child: self)
  }
  func visibleInset(h: CGFloat = 0, v: CGFloat = 0) -> Component {
    VisibleFrameInsets(insets: UIEdgeInsets(top: v, left: h, bottom: v, right: h), child: self)
  }
  func visibleInset(_ insets: UIEdgeInsets) -> Component {
    VisibleFrameInsets(insets: insets, child: self)
  }
  func visibleInset(_ insetProvider: @escaping (CGRect) -> UIEdgeInsets) -> Component {
    DynamicVisibleFrameInset(insetProvider: insetProvider, child: self)
  }
}
