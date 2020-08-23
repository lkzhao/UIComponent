//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

public struct Text: ViewComponent {
  public let attributedText: NSAttributedString
  public init(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 16)) {
    self.attributedText = NSAttributedString(string: text, attributes: [.font: font])
  }
  public init(_ attributedText: NSAttributedString) {
    self.attributedText = attributedText
  }
  public func layout(_ constraint: Constraint) -> TextRenderer {
    let fitSize = attributedText.boundingRect(with: constraint.maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
    let finalSize = CGSize(width: max(constraint.minSize.width, fitSize.width),
                           height: max(constraint.minSize.height, fitSize.height))
    return TextRenderer(attributedText: attributedText,
                        size: finalSize)
  }
}

public struct TextRenderer: ViewRenderer {
  public let attributedText: NSAttributedString
  public let id: String = UUID().uuidString
  public let size: CGSize
  public func updateView(_ label: UILabel) {
    label.attributedText = attributedText
  }
}
