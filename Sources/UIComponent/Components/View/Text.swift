//  Created by Luke Zhao on 8/22/20.

import UIKit

#if os(tvOS)
extension UIFont {
    public static let systemFontSize: Double = 16.0
}
#endif

public enum TextContent {
    case string(String)
    case attributedString(NSAttributedString)
}

public struct Text: Component {
    @Environment(\.font) var font
    public let content: TextContent
    public let numberOfLines: Int
    public let lineBreakMode: NSLineBreakMode
    public let isSwiftAttributedString: Bool

    public init(
        _ text: String,
        numberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) {
        self.content = .string(text)
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        self.isSwiftAttributedString = false
    }

    public init(
        _ text: String,
        font: UIFont,
        numberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) {
        self.content = .attributedString(NSAttributedString(string: text, attributes: [.font: font]))
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        self.isSwiftAttributedString = false
    }

    @available(iOS 15, *)
    public init(
        attributedString: AttributedString,
        numberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) {
        self.content = .attributedString(NSAttributedString(attributedString))
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        self.isSwiftAttributedString = true
    }

    public init(
        attributedString: NSAttributedString,
        numberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) {
        self.content = .attributedString(attributedString)
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        self.isSwiftAttributedString = false
    }

    public func layout(_ constraint: Constraint) -> TextRenderNode {
        let attributedString: NSAttributedString
        switch content {
        case .string(let string):
            attributedString = NSAttributedString(string: string, attributes: [.font: font])
        case .attributedString(let string):
            attributedString = string
        }
        if numberOfLines != 0 || isSwiftAttributedString {
            // Slower route
            //
            // Swift's AttributedString contains some attributes like NSInlinePresentationIntent
            // that are not processed by foundation's `boundingRect(size:...)` method or
            // CTFramesetter. Which will return incorrect sizing. So we fallback to TextKit.
            let textStorage = NSTextStorage()
            let layoutManager = NSLayoutManager()
            layoutManager.usesFontLeading = false
            textStorage.addLayoutManager(layoutManager)
            textStorage.setAttributedString(attributedString)
            let textContainer = NSTextContainer(size: constraint.maxSize)
            textContainer.lineFragmentPadding = 0
            textContainer.lineBreakMode = lineBreakMode
            textContainer.maximumNumberOfLines = numberOfLines
            layoutManager.addTextContainer(textContainer)
            layoutManager.ensureLayout(for: textContainer)
            let rect = layoutManager.usedRect(for: textContainer)
            return TextRenderNode(
                attributedString: attributedString,
                numberOfLines: numberOfLines,
                lineBreakMode: lineBreakMode,
                size: rect.size.bound(to: constraint)
            )
        } else {
            // Faster route
            let size = attributedString.boundingRect(with: constraint.maxSize,
                                                     options: [.usesLineFragmentOrigin],
                                                     context: nil).size
            return TextRenderNode(
                attributedString: attributedString,
                numberOfLines: numberOfLines,
                lineBreakMode: lineBreakMode,
                size: size.bound(to: constraint)
            )
        }
    }
}

public struct TextRenderNode: RenderNode {
    public let attributedString: NSAttributedString
    public let numberOfLines: Int
    public let lineBreakMode: NSLineBreakMode
    public let size: CGSize

    public init(attributedString: NSAttributedString, numberOfLines: Int, lineBreakMode: NSLineBreakMode, size: CGSize) {
        self.attributedString = attributedString
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        self.size = size
    }

    public func updateView(_ label: UILabel) {
        label.attributedText = attributedString
        label.numberOfLines = numberOfLines
        label.lineBreakMode = lineBreakMode
    }
}

public struct FontEnvironmentKey: EnvironmentKey {
    public static var defaultValue: UIFont {
        UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }
}

public extension EnvironmentValues {
    var font: UIFont {
        get { self[FontEnvironmentKey.self] }
        set { self[FontEnvironmentKey.self] = newValue }
    }
}

public extension Component {
    func font(_ font: UIFont) -> EnvironmentComponent<UIFont, Self> {
        environment(\.font, value: font)
    }
}
