//  Created by Luke Zhao on 8/22/20.

import UIKit

#if os(tvOS)
extension UIFont {
    public static let systemFontSize: Double = 16.0
}
#endif

/// An enumeration that represents the content of a `Text` component.
/// It can either be a plain `String` or an `NSAttributedString` for more complex styling.
public enum TextContent {
    case string(String, UIFont)
    case attributedString(NSAttributedString)

    // The ascender of the text content.
    var ascender: CGFloat {
        switch self {
        case .string(_, let font):
            return font.ascender
        case .attributedString(let string):
            return string.ascender
        }
    }

    // The ascender of the text content.
    var descender: CGFloat {
        switch self {
        case .string(_, let font):
            return font.descender
        case .attributedString(let string):
            return string.descender
        }
    }

    func apply(to label: UILabel) {
        switch self {
        case .string(let string, let font):
            label.attributedText = nil
            label.font = font
            label.text = string
        case .attributedString(let string):
            label.font = nil
            label.text = nil
            label.attributedText = string
        }
    }
}

/// A shared UILabel instance used for sizing text when `useSharedLabelForSizing` is true.
private let layoutLabel = UILabel()

/// A `Text` component represents a piece of text with styling and layout information.
/// It can be initialized with either a plain `String` or an `NSAttributedString`.
/// It also supports the new swift `AttributedString` from iOS 15 for more complex styling.
public struct Text: Component {
    /// A flag to determine if a shared UILabel should be used for sizing.
    public static var useSharedLabelForSizing = true

    /// Environment-injected font used when rendering plain strings.
    @Environment(\.font) var font
    /// Environment-injected text color used when rendering plain strings.
    @Environment(\.textColor) var textColor
    /// The content of the text, which can be a plain string or an attributed string.
    public let content: TextContent
    /// The maximum number of lines to display the text. 0 means no limit.
    public let numberOfLines: Int
    /// The mode to use for line breaking.
    public let lineBreakMode: NSLineBreakMode
    /// A flag indicating whether the content is a Swift `AttributedString`.
    public let isSwiftAttributedString: Bool

    /// Creates a `Text` component with a plain string.
    /// - Parameters:
    ///   - text: The plain string to display.
    ///   - numberOfLines: The maximum number of lines for the text.
    ///   - lineBreakMode: The line break mode to use.
    public init(
        _ text: String,
        numberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) {
        self.content = .string(text, UIFont.systemFont(ofSize: UIFont.systemFontSize))
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        self.isSwiftAttributedString = false
    }

    /// Creates a `Text` component with a plain string and a specific font.
    /// - Parameters:
    ///   - text: The plain string to display.
    ///   - font: The font to apply to the text.
    ///   - numberOfLines: The maximum number of lines for the text.
    ///   - lineBreakMode: The line break mode to use.
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

    /// Creates a `Text` component with a Swift `AttributedString`.
    /// - Parameters:
    ///   - attributedString: The `AttributedString` to display.
    ///   - numberOfLines: The maximum number of lines for the text.
    ///   - lineBreakMode: The line break mode to use.
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

    /// Creates a `Text` component with an `NSAttributedString`.
    /// - Parameters:
    ///   - attributedString: The `NSAttributedString` to display.
    ///   - numberOfLines: The maximum number of lines for the text.
    ///   - lineBreakMode: The line break mode to use.
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

    /// Lays out the text within the given constraints and returns a `TextRenderNode`.
    /// - Parameter constraint: The constraints to use for laying out the text.
    /// - Returns: A `TextRenderNode` that represents the laid out text.
    public func layout(_ constraint: Constraint) -> TextRenderNode {
        var content = content
        if case .string(let string, _) = content, let envFont = font {
            content = .string(string, envFont)
        }
        if Self.useSharedLabelForSizing, Thread.isMainThread {
            // Fastest route, but not thread safe.
            layoutLabel.numberOfLines = numberOfLines
            layoutLabel.lineBreakMode = lineBreakMode
            content.apply(to: layoutLabel)
            let size = layoutLabel.sizeThatFits(constraint.maxSize)
            return TextRenderNode(
                content: content,
                textColor: textColor,
                numberOfLines: numberOfLines,
                lineBreakMode: lineBreakMode,
                size: size.bound(to: constraint),
                ascender: content.ascender,
                descender: content.descender
            )
        }

        let attributedString: NSAttributedString
        switch content {
        case .string(let string, let font):
            var attributes: [NSAttributedString.Key: Any] = [.font: self.font ?? font]
            if let color = textColor {
                attributes[.foregroundColor] = color
            }
            attributedString = NSAttributedString(string: string, attributes: attributes)
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
                content: content,
                textColor: textColor,
                numberOfLines: numberOfLines,
                lineBreakMode: lineBreakMode,
                size: rect.size.bound(to: constraint),
                ascender: content.ascender,
                descender: content.descender
            )
        } else {
            // Faster route
            let size = attributedString.boundingRect(with: constraint.maxSize,
                                                     options: [.usesLineFragmentOrigin],
                                                     context: nil).size
            return TextRenderNode(
                content: content,
                textColor: textColor,
                numberOfLines: numberOfLines,
                lineBreakMode: lineBreakMode,
                size: size.bound(to: constraint),
                ascender: content.ascender,
                descender: content.descender
            )
        }
    }
}

/// A `TextRenderNode` represents a renderable text node with styling and layout information.
public struct TextRenderNode: RenderNode {
    /// The styled text to be rendered.
    public let content: TextContent
    /// The color of the text.
    public let textColor: UIColor?
    /// The maximum number of lines to use for rendering. 0 means no limit.
    public let numberOfLines: Int
    /// The technique to use for wrapping and truncating the text.
    public let lineBreakMode: NSLineBreakMode
    /// The calculated size of the rendered text.
    public let size: CGSize
    /// The ascender of the rendered text. Used for baseline alignment.
    public let ascender: CGFloat
    /// The descender of the rendered text. Used for baseline alignment.
    public let descender: CGFloat

    /// Initializes a new `TextRenderNode` with the given parameters.
    /// - Parameters:
    ///   - content: The styled text to be rendered.
    ///   - numberOfLines: The maximum number of lines to use for rendering.
    ///   - lineBreakMode: The technique to use for wrapping and truncating the text.
    ///   - size: The calculated size of the rendered text.
    ///   - ascender: The ascender of the rendered text.
    ///   - descender: The descender of the rendered text.
    public init(
        content: TextContent,
        textColor: UIColor? = nil,
        numberOfLines: Int,
        lineBreakMode: NSLineBreakMode,
        size: CGSize,
        ascender: CGFloat,
        descender: CGFloat
    ) {
        self.content = content
        self.textColor = textColor
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        self.size = size
        self.ascender = ascender
        self.descender = descender
    }

    /// Convenience initializer for creating a `TextRenderNode` with a plain string.
    public init(
        attributedString: NSAttributedString,
        numberOfLines: Int,
        lineBreakMode: NSLineBreakMode,
        size: CGSize,
        ascender: CGFloat,
        descender: CGFloat
    ) {
        self.init(
            content: .attributedString(attributedString),
            numberOfLines: numberOfLines,
            lineBreakMode: lineBreakMode,
            size: size,
            ascender: ascender,
            descender: descender
        )
    }

    /// Updates the provided `UILabel` with the render node's properties.
    /// - Parameter label: The `UILabel` to update with the text rendering information.
    public func updateView(_ label: UILabel) {
        content.apply(to: label)
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        label.lineBreakMode = lineBreakMode
    }
}
