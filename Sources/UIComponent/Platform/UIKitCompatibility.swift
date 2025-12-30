//  Created by Luke Zhao on 12/30/25.

#if os(macOS)
import AppKit
import QuartzCore

public typealias UIView = NSView
public typealias UIEdgeInsets = NSEdgeInsets

extension NSView {
    public var alpha: CGFloat {
        get { alphaValue }
        set { alphaValue = newValue }
    }

    public var center: CGPoint {
        get {
            CGPoint(x: frame.midX, y: frame.midY)
        }
        set {
            frame.origin = CGPoint(x: newValue.x - frame.size.width / 2, y: newValue.y - frame.size.height / 2)
        }
    }

    public var clipsToBounds: Bool {
        get { layer?.masksToBounds ?? false }
        set {
            wantsLayer = true
            layer?.masksToBounds = newValue
        }
    }

    public var backgroundColor: NSColor? {
        get {
            guard let cgColor = layer?.backgroundColor else { return nil }
            return NSColor(cgColor: cgColor)
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }

    public func setNeedsLayout() {
        needsLayout = true
    }

    public func layoutIfNeeded() {
        layoutSubtreeIfNeeded()
    }

    public func insertSubview(_ view: NSView, at index: Int) {
        if view.superview === self {
            view.removeFromSuperview()
        }

        let clampedIndex = max(0, min(index, subviews.count))
        guard clampedIndex < subviews.count else {
            addSubview(view)
            return
        }
        if subviews.isEmpty {
            addSubview(view)
            return
        }
        if clampedIndex == 0 {
            addSubview(view, positioned: .below, relativeTo: subviews.first)
        } else {
            addSubview(view, positioned: .above, relativeTo: subviews[clampedIndex - 1])
        }
    }

    public func point(inside point: CGPoint, with event: PlatformEvent?) -> Bool {
        bounds.contains(point)
    }

}

extension NSEdgeInsets {
    public static var zero: NSEdgeInsets {
        NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension NSColor {
    public static var separator: NSColor {
        separatorColor
    }
}

extension NSFont {
    public var lineHeight: CGFloat {
        ascender - descender + leading
    }
}

extension NSView {
    private struct UIComponentAssociatedKeys {
        static var uiComponentMaskView: Void?
    }

    public var mask: NSView? {
        get { objc_getAssociatedObject(self, &UIComponentAssociatedKeys.uiComponentMaskView) as? NSView }
        set {
            objc_setAssociatedObject(self, &UIComponentAssociatedKeys.uiComponentMaskView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            wantsLayer = true
            if let newValue {
                newValue.wantsLayer = true
                layer?.mask = newValue.layer
            } else {
                layer?.mask = nil
            }
        }
    }
}
#endif
