//
//  InsetLayout.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

open class InsetLayoutProvider: Provider {
  var insets: UIEdgeInsets
  var child: Provider

  init(insets: UIEdgeInsets, child: Provider) {
    self.insets = insets
    self.child = child
  }

  open func layout(size: CGSize) -> CGSize {
    return child.layout(size: size.insets(by: insets)).insets(by: -insets)
  }
  open func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    return child.views(in: frame.inset(by: -insets)).map {
      ($0.0, $0.1 + CGPoint(x: insets.left, y: insets.top))
    }
  }
  open func getIntrinsicWidth(height: CGFloat) -> CGFloat {
    let vInsets = insets.bottom + insets.top
    let hInsets = insets.left + insets.right
    return child.getIntrinsicWidth(height: height - vInsets) + hInsets
  }
  open func getIntrinsicHeight(width: CGFloat) -> CGFloat {
    let vInsets = insets.bottom + insets.top
    let hInsets = insets.left + insets.right
    return child.getIntrinsicHeight(width: width - hInsets) + vInsets
  }
}
