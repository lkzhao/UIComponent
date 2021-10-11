//  Created by Luke Zhao on 8/22/20.

import UIKit

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
    let textContainer = NSTextContainer(size: constraint.maxSize)
    textContainer.maximumNumberOfLines = numberOfLines
    textContainer.lineFragmentPadding = 0
    
    let layoutManager = NSLayoutManager()
    layoutManager.addTextContainer(textContainer)
    
    let textStorage = NSTextStorage(attributedString: attributedText)
    textStorage.addLayoutManager(layoutManager)
    
    layoutManager.ensureLayout(for: textContainer)
    
    let rect = layoutManager.usedRect(for: textContainer)
    return TextRenderNode(attributedText: attributedText, numberOfLines: numberOfLines, size: rect.size.bound(to: constraint))
  }
}

public struct TextRenderNode: ViewRenderNode {
  public let attributedText: NSAttributedString
  public let numberOfLines: Int
  public let size: CGSize
  public func updateView(_ label: UILabel) {
    label.attributedText = attributedText
    label.numberOfLines = numberOfLines
  }
}
