//
//  Separator.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2/12/20.
//

import UIKit

public class Separator: ViewAdapter<UIView> {
  public var color: UIColor

  public init(key: String = UUID().uuidString, color: UIColor = UIColor(white: 0.9, alpha: 1.0)) {
    self.color = color
    super.init(key: key)
  }

  public override func updateView(_ view: UIView) {
    view.backgroundColor = color
    super.updateView(view)
  }

  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: size.width, height: 1)
  }
}
