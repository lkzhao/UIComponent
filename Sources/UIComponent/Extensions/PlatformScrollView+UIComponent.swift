//  Created by Luke on 4/16/17.

extension PlatformScrollView {
    public var visibleFrame: CGRect {
#if os(macOS)
        contentView.bounds
#else
        bounds
#endif
    }

    public var visibleFrameLessInset: CGRect {
#if os(macOS)
        let inset: PlatformEdgeInsets
        if #available(macOS 10.10, *) {
            inset = contentInsets
        } else {
            inset = .zero
        }
        return visibleFrame.inset(by: inset)
#else
        visibleFrame.inset(by: contentInset)
#endif
    }

    public var adjustedSize: CGSize {
#if os(macOS)
        let inset: PlatformEdgeInsets
        if #available(macOS 10.10, *) {
            inset = contentInsets
        } else {
            inset = .zero
        }
        return visibleFrame.size.inset(by: inset)
#else
        bounds.size.inset(by: adjustedContentInset)
#endif
    }

    public var offsetFrame: CGRect {
#if os(macOS)
        let inset: PlatformEdgeInsets
        if #available(macOS 10.10, *) {
            inset = contentInsets
        } else {
            inset = .zero
        }
        let contentSize = documentView?.bounds.size ?? .zero
        let viewportSize = contentView.bounds.size
        return CGRect(
            x: -inset.left,
            y: -inset.top,
            width: max(0, contentSize.width - viewportSize.width + inset.right + inset.left),
            height: max(0, contentSize.height - viewportSize.height + inset.bottom + inset.top)
        )
#else
        let inset = adjustedContentInset
        return CGRect(
            x: -inset.left,
            y: -inset.top,
            width: max(0, contentSize.width - bounds.width + inset.right + inset.left),
            height: max(0, contentSize.height - bounds.height + inset.bottom + inset.top)
        )
#endif
    }

    public func absoluteLocation(for point: CGPoint) -> CGPoint {
#if os(macOS)
        return point - contentView.bounds.origin
#else
        return point - contentOffset
#endif
    }

    public func scrollTo(edge: PlatformRectEdge, animated: Bool) {
#if os(macOS)
        let currentOffset = contentView.bounds.origin
        let target: CGPoint
        switch edge {
        case PlatformRectEdge.top:
            target = CGPoint(x: currentOffset.x, y: offsetFrame.minY)
        case PlatformRectEdge.bottom:
            target = CGPoint(x: currentOffset.x, y: offsetFrame.maxY)
        case PlatformRectEdge.left:
            target = CGPoint(x: offsetFrame.minX, y: currentOffset.y)
        case PlatformRectEdge.right:
            target = CGPoint(x: offsetFrame.maxX, y: currentOffset.y)
        default:
            return
        }
        contentView.scroll(to: target)
        reflectScrolledClipView(contentView)
#else
        let target: CGPoint
        switch edge {
        case PlatformRectEdge.top:
            target = CGPoint(x: contentOffset.x, y: offsetFrame.minY)
        case PlatformRectEdge.bottom:
            target = CGPoint(x: contentOffset.x, y: offsetFrame.maxY)
        case PlatformRectEdge.left:
            target = CGPoint(x: offsetFrame.minX, y: contentOffset.y)
        case PlatformRectEdge.right:
            target = CGPoint(x: offsetFrame.maxX, y: contentOffset.y)
        default:
            return
        }
        setContentOffset(target, animated: animated)
#endif
    }
}

