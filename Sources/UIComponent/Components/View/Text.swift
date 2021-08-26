//  Created by Luke Zhao on 8/22/20.

import UIKit

private let sizingLabel = UILabel()

public struct Text: ViewComponent {
  public let attributedText: NSAttributedString
  public let numberOfLines: Int
  public init(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 16), numberOfLines: Int = 0) {
    self.attributedText = NSAttributedString(string: text, attributes: [.font: font])
    self.numberOfLines = numberOfLines
  }
  public init(_ attributedText: NSAttributedString, numberOfLines: Int = 0) {
    self.attributedText = attributedText
    self.numberOfLines = numberOfLines
  }
  public func layout(_ constraint: Constraint) -> TextRenderNode {
    sizingLabel.attributedText = attributedText
    sizingLabel.numberOfLines = numberOfLines
    let size = sizingLabel.sizeThatFits(constraint.maxSize)
    return TextRenderNode(attributedText: attributedText, size: size.bound(to: constraint))
  }
}

public struct TextRenderNode: ViewRenderNode {
  public let attributedText: NSAttributedString
  public let size: CGSize
  public func updateView(_ label: UILabel) {
    label.attributedText = attributedText
    label.numberOfLines = 0
  }
}
