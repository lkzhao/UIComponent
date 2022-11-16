//  Created by Luke Zhao on 8/22/20.

import UIKit

public struct Text: ViewComponent {
    public let attributedText: NSAttributedString
    public let numberOfLines: Int
    public let lineBreakMode: NSLineBreakMode

    @available(iOS 15, *)
    public init(
        localized: String.LocalizationValue,
        font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize),
        numberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) {
        self.attributedText = NSAttributedString(string: String(localized: localized), attributes: [.font: font])
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
    }

    @available(iOS 15, *)
    public init(
        _ attributedText: AttributedString,
        numberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) {
        self.attributedText = NSAttributedString(attributedText)
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
    }

    public init(
        _ text: String,
        font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize),
        numberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) {
        self.attributedText = NSAttributedString(string: text, attributes: [.font: font])
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
    }

    public init(
        _ attributedText: NSAttributedString,
        numberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) {
        self.attributedText = attributedText
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
    }

    public func layout(_ constraint: Constraint) -> TextRenderNode {
        guard numberOfLines != 0 else {
            return TextRenderNode(
                attributedText: attributedText,
                numberOfLines: numberOfLines,
                lineBreakMode: lineBreakMode,
                size: attributedText.boundingRect(with: constraint.maxSize, options: [.usesLineFragmentOrigin], context: nil).size.bound(to: constraint)
            )
        }
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        layoutManager.usesFontLeading = false
        textStorage.addLayoutManager(layoutManager)

        textStorage.setAttributedString(attributedText)
        let textContainer = NSTextContainer(size: constraint.maxSize)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        layoutManager.addTextContainer(textContainer)
        layoutManager.ensureLayout(for: textContainer)
        let rect = layoutManager.usedRect(for: textContainer)
        return TextRenderNode(
            attributedText: attributedText,
            numberOfLines: numberOfLines,
            lineBreakMode: lineBreakMode,
            size: rect.size.bound(to: constraint)
        )
    }
}

public struct TextRenderNode: ViewRenderNode {
    public let attributedText: NSAttributedString
    public let numberOfLines: Int
    public let lineBreakMode: NSLineBreakMode
    public let size: CGSize

    public init(attributedText: NSAttributedString, numberOfLines: Int, lineBreakMode: NSLineBreakMode, size: CGSize) {
        self.attributedText = attributedText
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        self.size = size
    }

    public func updateView(_ label: UILabel) {
        label.attributedText = attributedText
        label.numberOfLines = numberOfLines
        label.lineBreakMode = lineBreakMode
    }
}
