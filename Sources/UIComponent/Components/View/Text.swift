//  Created by Luke Zhao on 8/22/20.

#if os(macOS)
import AppKit
#endif

/// An enumeration that represents the content of a `Text` component.
/// It can either be a plain `String` or an `NSAttributedString` for more complex styling.
public enum TextContent {
    case string(String, PlatformFont)
    case attributedString(NSAttributedString)

    var ascender: CGFloat {
        switch self {
        case .string(_, let font):
            return font.ascender
        case .attributedString(let string):
            return string.ascender
        }
    }

    var descender: CGFloat {
        switch self {
        case .string(_, let font):
            return font.descender
        case .attributedString(let string):
            return string.descender
        }
    }

    func apply(to label: PlatformLabel) {
#if canImport(UIKit)
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
#else
        label.allowsEditingTextAttributes = true
        switch self {
        case .string(let string, let font):
            label.font = font
            label.attributedStringValue = NSAttributedString(string: string, attributes: [.font: font])
        case .attributedString(let string):
            label.attributedStringValue = string
        }
#endif
    }
}

/// A `Text` component represents a piece of text with styling and layout information.
/// It can be initialized with either a plain `String` or an `NSAttributedString`.
/// It also supports the new swift `AttributedString` from iOS 15 for more complex styling.
public struct Text: Component {
    @Environment(\.font) var font
    @Environment(\.textColor) var textColor

    public let content: TextContent
    public let numberOfLines: Int
    public let lineBreakMode: NSLineBreakMode
    public let isSwiftAttributedString: Bool

    public init(
        _ text: String,
        numberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) {
        self.content = .string(text, PlatformFont.systemFont(ofSize: PlatformFont.systemFontSize))
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        self.isSwiftAttributedString = false
    }

    public init(
        _ text: String,
        font: PlatformFont,
        numberOfLines: Int = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) {
        self.content = .attributedString(NSAttributedString(string: text, attributes: [.font: font]))
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        self.isSwiftAttributedString = false
    }

    @available(iOS 15, macOS 12, tvOS 15, *)
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
        var content = content
        if case .string(let string, _) = content, let envFont = font {
            content = .string(string, envFont)
        }

        let attributedString: NSAttributedString
        switch content {
        case .string(let string, let baseFont):
            var attributes: [NSAttributedString.Key: Any] = [.font: self.font ?? baseFont]
            if let color = textColor {
                attributes[.foregroundColor] = color
            }
            attributedString = NSAttributedString(string: string, attributes: attributes)
        case .attributedString(let string):
            attributedString = string
        }

        if numberOfLines != 0 || isSwiftAttributedString {
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
            let size = attributedString.boundingRect(
                with: constraint.maxSize,
                options: [.usesLineFragmentOrigin],
                context: nil
            ).size
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

public struct TextRenderNode: RenderNode {
    public typealias View = PlatformLabel

    public let content: TextContent
    public let textColor: PlatformColor?
    public let numberOfLines: Int
    public let lineBreakMode: NSLineBreakMode
    public let size: CGSize
    public let ascender: CGFloat
    public let descender: CGFloat

    public init(
        content: TextContent,
        textColor: PlatformColor? = nil,
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

    public func makeView() -> PlatformLabel {
#if canImport(UIKit)
        UILabel()
#else
        let label = NSTextField(labelWithString: "")
        label.isSelectable = false
        label.isEditable = false
        label.isBezeled = false
        label.drawsBackground = false
        label.allowsEditingTextAttributes = true
        return label
#endif
    }

    public func updateView(_ view: PlatformLabel) {
#if canImport(UIKit)
        content.apply(to: view)
        view.numberOfLines = numberOfLines
        view.lineBreakMode = lineBreakMode
        view.textColor = textColor
#else
        view.allowsEditingTextAttributes = true
        content.apply(to: view)
        view.textColor = textColor
        view.cell?.lineBreakMode = lineBreakMode
        if numberOfLines != 0 {
            view.maximumNumberOfLines = numberOfLines
        } else {
            view.maximumNumberOfLines = 0
        }
#endif
    }
}

