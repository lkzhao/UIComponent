//
//  File.swift
//  
//
//  Created by Luke Zhao on 2/5/20.
//

import UIKit

open class Text: ViewAdapter<UILabel> {
  public var attributedText: NSAttributedString
  public init(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 16)) {
    self.attributedText = NSAttributedString(string: text, attributes: [.font: font])
    super.init()
  }
  public init(_ attributedText: NSAttributedString) {
    self.attributedText = attributedText
    super.init()
  }
  public override func updateView(_ view: UILabel) {
    view.attributedText = attributedText
    super.updateView(view)
  }
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    return attributedText.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
  }
}
