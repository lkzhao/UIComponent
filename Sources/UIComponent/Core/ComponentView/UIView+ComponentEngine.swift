//  Created by Luke Zhao on 7/17/24.

#if canImport(UIKit)
extension PlatformView {
    // Access to the underlying Component Engine
    public var componentEngine: ComponentEngine {
        get {
            if let componentEngine = _componentEngine {
                return componentEngine
            }
            let componentEngine = ComponentEngine(view: self)
            _ = UIView.swizzle_setBounds
            _ = UIView.swizzle_layoutSubviews
            _ = UIView.swizzle_sizeThatFits
            _ = UIScrollView.swizzle_safeAreaInsetsDidChange
            _ = UIScrollView.swizzle_setContentInset
            _componentEngine = componentEngine
            return componentEngine
        }
    }
}
#else
extension PlatformView {
    public var componentEngine: ComponentEngine {
        if let componentEngine = _componentEngine {
            return componentEngine
        }
        let componentEngine = ComponentEngine(view: self)
        _componentEngine = componentEngine
#if os(macOS)
        _ = NSView.swizzle_layout
#endif
        _startObservingLayoutForUIComponent()
        return componentEngine
    }
}
#endif

private struct AssociatedKeys {
    static var componentEngine: Void?
    static var onFirstReload: Void?
    static var layoutObserverTokens: Void?
}

extension PlatformView {
    fileprivate var _componentEngine: ComponentEngine? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.componentEngine) as? ComponentEngine
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.componentEngine,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

#if os(macOS)
    fileprivate func _startObservingLayoutForUIComponent() {
        guard objc_getAssociatedObject(self, &AssociatedKeys.layoutObserverTokens) == nil else { return }

        postsFrameChangedNotifications = true
        postsBoundsChangedNotifications = true

        let center = NotificationCenter.default
        let tokens: [NSObjectProtocol] = [
            center.addObserver(forName: NSView.frameDidChangeNotification, object: self, queue: nil) { [weak self] _ in
                self?._componentEngine?.layoutSubview()
            },
            center.addObserver(forName: NSView.boundsDidChangeNotification, object: self, queue: nil) { [weak self] _ in
                self?._componentEngine?.layoutSubview()
            },
        ]
        objc_setAssociatedObject(self, &AssociatedKeys.layoutObserverTokens, tokens, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
#endif
}

#if os(macOS)
extension NSView {
    static let swizzle_layout: Void = {
        guard let originalMethod = class_getInstanceMethod(NSView.self, NSSelectorFromString("layout")),
              let swizzledMethod = class_getInstanceMethod(NSView.self, #selector(swizzled_layout))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_layout() {
        swizzled_layout()
        _componentEngine?.layoutSubview()
    }
}
#endif

#if canImport(UIKit)
extension PlatformView {
    static let swizzle_sizeThatFits: Void = {
        guard let originalMethod = class_getInstanceMethod(UIView.self, #selector(sizeThatFits(_:))),
              let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_sizeThatFits(_:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_sizeThatFits(_ size: CGSize) -> CGSize {
        _componentEngine?.sizeThatFits(size) ?? swizzled_sizeThatFits(size)
    }

    static let swizzle_layoutSubviews: Void = {
        guard let originalMethod = class_getInstanceMethod(UIView.self, #selector(layoutSubviews)),
              let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_layoutSubviews))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_layoutSubviews() {
        swizzled_layoutSubviews()
        _componentEngine?.layoutSubview()
    }

    static let swizzle_setBounds: Void = {
        guard let originalMethod = class_getInstanceMethod(UIView.self, #selector(setter: bounds)),
              let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_setBounds(_:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_setBounds(_ bounds: CGRect) {
        swizzled_setBounds(bounds)
        _componentEngine?.setNeedsRender()
    }
}

extension UIScrollView {
    static let swizzle_safeAreaInsetsDidChange: Void = {
        guard let originalMethod = class_getInstanceMethod(UIScrollView.self, #selector(safeAreaInsetsDidChange)),
              let swizzledMethod = class_getInstanceMethod(UIScrollView.self, #selector(swizzled_safeAreaInsetsDidChange))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    static let swizzle_setContentInset: Void = {
        guard let originalMethod = class_getInstanceMethod(UIScrollView.self, #selector(setter: contentInset)),
              let swizzledMethod = class_getInstanceMethod(UIScrollView.self, #selector(swizzled_setContentInset(_:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_safeAreaInsetsDidChange() {
        guard responds(to: #selector(swizzled_safeAreaInsetsDidChange)) else { return }
        swizzled_safeAreaInsetsDidChange()
        if let componentEngine = _componentEngine, contentInsetAdjustmentBehavior != .never {
            componentEngine.setNeedsReload()
        }
    }

    @objc func swizzled_setContentInset(_ contentInset: UIEdgeInsets) {
        // when contentOffset is at the top, and contentSize is set
        // changing contentInset will not trigger a contentOffset change
        // we manually adjust the contentOffset back to the top
        // same for the horizontal axis
        let yAtTop = contentOffset.y <= -adjustedContentInset.top
        let xAtLeft = contentOffset.x <= -adjustedContentInset.left
        swizzled_setContentInset(contentInset)
        var newContentOffset = contentOffset
        if yAtTop {
            newContentOffset.y = -adjustedContentInset.top
        }
        if xAtLeft {
            newContentOffset.x = -adjustedContentInset.left
        }
        if newContentOffset != contentOffset {
            contentOffset = newContentOffset
        }
    }
}
#endif
