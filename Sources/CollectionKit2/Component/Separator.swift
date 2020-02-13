//
//  Separator.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2/12/20.
//

import Foundation

class Separator: ViewAdapter<UIView> {
  let color: UIColor

  init(key: String = UUID().uuidString, color: UIColor = .gray) {
    self.color = color
    super.init(key: key)
  }

  override func updateView(_ view: UIView) {
    view.backgroundColor = color
    super.updateView(view)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: size.width, height: 1)
  }
}
