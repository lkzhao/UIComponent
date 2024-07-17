//
//  UIView+ComponentEngine.swift
//
//
//  Created by Luke Zhao on 7/17/24.
//

import UIKit

extension UIView {
    // Access to the underlying Component Engine
    public var engine: ComponentEngine {
        get {
            if let engine = _engine {
                return engine
            }
            let engine = ComponentEngine(view: self)
            _ = UIView.swizzle_setBounds
            _ = UIView.swizzle_layoutSubviews
            _ = UIView.swizzle_sizeThatFits
            _ = UIScrollView.swizzle_safeAreaInsetsDidChange
            _engine = engine
            return engine
        }
    }
}

private struct AssociatedKeys {
    static var componentEngine: Void?
    static var onFirstReload: Void?
}

extension UIView {
    fileprivate var _engine: ComponentEngine? {
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

    static let swizzle_sizeThatFits: Void = {
        guard let originalMethod = class_getInstanceMethod(UIView.self, #selector(sizeThatFits(_:))),
              let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_sizeThatFits(_:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_sizeThatFits(_ size: CGSize) -> CGSize {
        _engine?.sizeThatFits(size) ?? swizzled_sizeThatFits(size)
    }

    static let swizzle_layoutSubviews: Void = {
        guard let originalMethod = class_getInstanceMethod(UIView.self, #selector(layoutSubviews)),
              let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_layoutSubviews))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_layoutSubviews() {
        swizzled_layoutSubviews()
        _engine?.layoutSubview()
    }

    static let swizzle_setBounds: Void = {
        guard let originalMethod = class_getInstanceMethod(UIView.self, NSSelectorFromString("setBounds:")),
              let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_setBounds(_:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_setBounds(_ bounds: CGRect) {
        swizzled_setBounds(bounds)
        _engine?.setNeedsRender()
    }
}

extension UIScrollView {
    static let swizzle_safeAreaInsetsDidChange: Void = {
        guard let originalMethod = class_getInstanceMethod(UIScrollView.self, #selector(safeAreaInsetsDidChange)),
              let swizzledMethod = class_getInstanceMethod(UIScrollView.self, #selector(swizzled_safeAreaInsetsDidChange))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_safeAreaInsetsDidChange() {
        guard responds(to: #selector(swizzled_safeAreaInsetsDidChange)) else { return }
        swizzled_safeAreaInsetsDidChange()
        if let engine = _engine, contentInsetAdjustmentBehavior != .never {
            engine.setNeedsReload()
        }
    }
}

