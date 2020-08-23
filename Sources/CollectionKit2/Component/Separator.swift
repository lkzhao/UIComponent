//
//  Separator.swift
//  CollectionKit3
//
//  Created by Luke Zhao on 2/12/20.
//

import UIKit

public class Separator: ViewAdapter<UIView> {
  public var color: UIColor

  public init(id: String = UUID().uuidString, color: UIColor = UIColor(white: 0.9, alpha: 1.0)) {
    self.color = color
    super.init(id: id)
  }

  public override func updateView(_ view: UIView) {
    view.backgroundColor = color
    super.updateView(view)
  }

  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: size.width.isFinite ? size.width : 0, height: 1)
  }
}
