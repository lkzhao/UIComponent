//  Created by Luke Zhao on 8/27/20.

import UIKit

/// A UIScrollView that can render components
///
/// You can set the ``component`` property with your component tree for it to render
/// The render happens on the next layout cycle. But you can call ``reloadData`` to force it to render.
///
/// Most of the code is written in ``ComponentDisplayableView``, since both ``ComponentView``
/// and ``ComponentScrollView`` supports rendering components.
///
/// See ``ComponentDisplayableView`` for usage details.
open class ComponentScrollView: UIScrollView, ComponentDisplayableView {
    lazy public var engine: ComponentEngine = ComponentEngine(view: self)

    public var onFirstReload: ((ComponentScrollView) -> Void)? {
        didSet {
            if let onFirstReload {
                engine.onFirstReload = { [weak self] in
                    guard let self = self else { return }
                    onFirstReload(self)
                }
            } else {
                engine.onFirstReload = nil
            }
        }
    }

    open override var contentOffset: CGPoint {
        didSet {
            setNeedsLayout()
        }
    }

    public var contentView: UIView? {
        get { return engine.contentView }
        set { engine.contentView = newValue }
    }

    open override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        if contentInsetAdjustmentBehavior != .never {
            setNeedsInvalidateLayout()
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        engine.layoutSubview()
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        engine.sizeThatFits(size)
    }

    @discardableResult open func scrollTo(id: String, animated: Bool) -> Bool {
        if let frame = engine.renderNode?.frame(id: id) {
            scrollRectToVisible(frame, animated: animated)
            return true
        } else {
            return false
        }
    }
}
