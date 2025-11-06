//
//  File.swift
//  CodeExample
//
//  Created by Luke Zhao on 11/4/25.
//

import UIKit

extension UIView {
    private struct AssociateKey {
        static var borderColor: Void?
        static var shadowColor: Void?
        static var hitTestSlop: Void?
        static var hasRegisteredForTraitCollectionChange: Void?
    }

    @objc open var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }

    @objc open var cornerCurve: CALayerCornerCurve {
        get { layer.cornerCurve }
        set { layer.cornerCurve = newValue }
    }

    @objc open var maskedCorners: CACornerMask {
        get { layer.maskedCorners }
        set { layer.maskedCorners = newValue }
    }

    @objc open var zPosition: CGFloat {
        get { layer.zPosition }
        set { layer.zPosition = newValue }
    }

    @objc open var borderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    @objc open var shadowOpacity: CGFloat {
        get { CGFloat(layer.shadowOpacity) }
        set { layer.shadowOpacity = Float(newValue) }
    }

    @objc open var shadowRadius: CGFloat {
        get { layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }

    @objc open var shadowOffset: CGSize {
        get { layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }

    @objc open var shadowPath: UIBezierPath? {
        get { layer.shadowPath.map { UIBezierPath(cgPath: $0) } }
        set { layer.shadowPath = newValue?.cgPath }
    }

    @objc open var hitTestSlop: UIEdgeInsets {
        get {
            (objc_getAssociatedObject(self, &AssociateKey.hitTestSlop) as? NSValue)?.uiEdgeInsetsValue ?? .zero
        }
        set {
            _ = UIView.swizzlePointInside
            objc_setAssociatedObject(self, &AssociateKey.hitTestSlop, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc open var borderColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &AssociateKey.borderColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.borderColor, newValue, .OBJC_ASSOCIATION_RETAIN)
            layer.borderColor = borderColor?.resolvedColor(with: traitCollection).cgColor
            if #available(iOS 17.0, *) {
                registerTraitCollectionChangeIfNeeded()
            } else {
                _ = UIView.swizzleTraitCollection
            }
        }
    }

    @objc open var shadowColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &AssociateKey.shadowColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.shadowColor, newValue, .OBJC_ASSOCIATION_RETAIN)
            layer.shadowColor = shadowColor?.resolvedColor(with: traitCollection).cgColor
            if #available(iOS 17.0, *) {
                registerTraitCollectionChangeIfNeeded()
            } else {
                _ = UIView.swizzleTraitCollection
            }
        }
    }

    @objc open var firstResponder: UIView? {
        if isFirstResponder {
            return self
        }
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        return nil
    }

    @objc open class var isInAnimationBlock: Bool {
        UIView.perform(NSSelectorFromString("_isInAnimationBlock")) != nil
    }

    private static let swizzlePointInside: Void = {
        guard let originalMethod = class_getInstanceMethod(UIView.self, #selector(point(inside:with:))),
              let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_point(inside:with:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    private static let swizzleTraitCollection: Void = {
        guard let originalMethod = class_getInstanceMethod(UIView.self, #selector(traitCollectionDidChange(_:))),
              let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_traitCollectionDidChange(_:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        swizzled_traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColorBasedOnTraitCollection()
        }
    }

    @objc func swizzled_point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.inset(by: hitTestSlop).contains(point)
    }

    private var hasRegisteredForTraitCollectionChange: Bool {
        get {
            objc_getAssociatedObject(self, &AssociateKey.hasRegisteredForTraitCollectionChange) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.hasRegisteredForTraitCollectionChange, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    private func registerTraitCollectionChangeIfNeeded() {
        if #available(iOS 17.0, *), !hasRegisteredForTraitCollectionChange {
            hasRegisteredForTraitCollectionChange = true
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: Self, previousTraitCollection) in
                if view.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                    view.updateColorBasedOnTraitCollection()
                }
            }
        }
    }

    private func updateColorBasedOnTraitCollection() {
        if let borderColor {
            layer.borderColor = borderColor.resolvedColor(with: traitCollection).cgColor
        }
        if let shadowColor {
            layer.shadowColor = shadowColor.resolvedColor(with: traitCollection).cgColor
        }
    }
}

