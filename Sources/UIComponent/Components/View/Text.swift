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
    case string(String)
    case attributedString(NSAttributedString)
}

/// A `Text` component represents a piece of text with styling and layout information.
/// It can be initialized with either a plain `String` or an `NSAttributedString`.
/// It also supports the new swift `AttributedString` from iOS 15 for more complex styling.
public struct Text: Component {
    /// Environment-injected font used when rendering plain strings.
    @Environment(\.font) var font
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
        self.content = .string(text)
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

/// A `TextRenderNode` represents a renderable text node with styling and layout information.
public struct TextRenderNode: RenderNode {
    /// The styled text to be rendered.
    public let attributedString: NSAttributedString
    /// The maximum number of lines to use for rendering. 0 means no limit.
    public let numberOfLines: Int
    /// The technique to use for wrapping and truncating the text.
    public let lineBreakMode: NSLineBreakMode
    /// The calculated size of the rendered text.
    public let size: CGSize

    /// Initializes a new `TextRenderNode` with the given parameters.
    /// - Parameters:
    ///   - attributedString: The styled text to be rendered.
    ///   - numberOfLines: The maximum number of lines to use for rendering.
    ///   - lineBreakMode: The technique to use for wrapping and truncating the text.
    ///   - size: The calculated size of the rendered text.
    public init(attributedString: NSAttributedString, numberOfLines: Int, lineBreakMode: NSLineBreakMode, size: CGSize) {
        self.attributedString = attributedString
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        self.size = size
    }

    /// Updates the provided `UILabel` with the render node's properties.
    /// - Parameter label: The `UILabel` to update with the text rendering information.
    public func updateView(_ label: UILabel) {
        label.attributedText = attributedString
        label.numberOfLines = numberOfLines
        label.lineBreakMode = lineBreakMode
    }
}

/// The key for accessing the default font from the environment.
public struct FontEnvironmentKey: EnvironmentKey {
    /// The default value for the font environment key.
    public static var defaultValue: UIFont {
        UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }
}

/// Extension to provide easy access and modification of the font environment value.
public extension EnvironmentValues {
    /// The font value in the environment.
    var font: UIFont {
        get { self[FontEnvironmentKey.self] }
        set { self[FontEnvironmentKey.self] = newValue }
    }
}

/// Extension to allow components to modify the font environment value.
public extension Component {
    /// Modifies the font environment value for the component.
    /// - Parameter font: The UIFont to be set in the environment.
    /// - Returns: An environment component with the new font value.
    func font(_ font: UIFont) -> EnvironmentComponent<UIFont, Self> {
        environment(\.font, value: font)
    }
}
