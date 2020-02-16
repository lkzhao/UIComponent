//
//  File.swift
//  
//
//  Created by Luke Zhao on 2/5/20.
//

import UIKit

open class Text: ViewAdapter<UILabel> {
  var text: String
  var font: UIFont
  public init(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 16)) {
    self.text = text
    self.font = font
    super.init()
  }
  public override func updateView(_ view: UILabel) {
    view.font = font
    view.text = text
    super.updateView(view)
  }
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    return (text as NSString).boundingRect(with: size, options: [], attributes: [.font: font], context: nil).size
  }
}

public extension Text {
  func color(_ color: UIColor) -> Self {
    with(\.textColor, color)
  }
  func numberOfLines(_ lines: Int) -> Self {
    with(\.numberOfLines, lines)
  }
  func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
    with(\.textAlignment, textAlignment)
  }
}
