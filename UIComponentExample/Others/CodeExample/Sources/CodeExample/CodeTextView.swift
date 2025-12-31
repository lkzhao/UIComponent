//  Created by Luke Zhao on 11/4/25.

@preconcurrency import UIComponent
import Highlightr

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIKit

final class CodeTextView: UITextView {
    private let highlightr = Highlightr()!

    var code: String = "" {
        didSet {
            attributedText = highlightr.highlight(code, as: "swift")
        }
    }

    init() {
        super.init(frame: .zero, textContainer: nil)
        backgroundColor = .clear
        isEditable = false
        isScrollEnabled = false
        updateColorBasedOnTraitCollection()
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: Self, previousTraitCollection) in
                if view.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                    view.updateColorBasedOnTraitCollection()
                }
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateColorBasedOnTraitCollection() {
        highlightr.setTheme(to: traitCollection.userInterfaceStyle == .dark ? "monokai" : "xcode")
        highlightr.theme.setCodeFont(UIFont.monospacedSystemFont(ofSize: 14, weight: .regular))
        attributedText = highlightr.highlight(code, as: "swift")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColorBasedOnTraitCollection()
        }
    }
}

#elseif os(macOS)
import AppKit

final class CodeTextView: NSTextView {
    private let highlightr = Highlightr()!

    var code: String = "" {
        didSet {
            applyHighlighting()
        }
    }

    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: frameRect.size)
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        super.init(frame: frameRect, textContainer: textContainer)

        drawsBackground = false
        isEditable = false
        isSelectable = true
        textContainerInset = .zero
        applyHighlighting()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        drawsBackground = false
        isEditable = false
        isSelectable = true
        textContainerInset = .zero
        applyHighlighting()
    }

    private func applyHighlighting() {
        let themeName = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? "monokai" : "xcode"
        highlightr.setTheme(to: themeName)
        highlightr.theme.setCodeFont(NSFont.monospacedSystemFont(ofSize: 14, weight: .regular))
        let highlighted = highlightr.highlight(code, as: "swift") ?? NSAttributedString(string: code)
        textStorage?.setAttributedString(highlighted)
    }

    static func sizeThatFits(code: String, in maxSize: CGSize) -> CGSize {
        let highlightr = Highlightr()!
        let themeName = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? "monokai" : "xcode"
        highlightr.setTheme(to: themeName)
        highlightr.theme.setCodeFont(NSFont.monospacedSystemFont(ofSize: 14, weight: .regular))
        let highlighted = highlightr.highlight(code, as: "swift") ?? NSAttributedString(string: code)

        let bounding = highlighted.boundingRect(
            with: CGSize(width: maxSize.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        return CGSize(width: ceil(bounding.width), height: ceil(bounding.height)).bound(to: Constraint(maxSize: maxSize))
    }
}

#else
final class CodeTextView: PlatformView {}
#endif
