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
        let size = attributedText.boundingRect(with: constraint.maxSize, options: [.usesLineFragmentOrigin], context: nil).size
        return TextRenderer(attributedText: attributedText, size: size.bound(to: constraint))
    }
}

public struct TextRenderer: ViewRenderer {
    public let attributedText: NSAttributedString
    public let size: CGSize
    public func updateView(_ label: UILabel) {
        label.attributedText = attributedText
        label.numberOfLines = 0
    }
}
