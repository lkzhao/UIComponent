//  Created by Luke Zhao on 11/4/25.

@preconcurrency import UIComponent
import Highlightr
import UIKit

class CodeTextView: UITextView {
    let highlightr = Highlightr()!

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
