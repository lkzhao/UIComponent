//  Created by Luke on 4/16/17.


import UIKit

extension UIScrollView {
    public var visibleFrame: CGRect {
        bounds
    }

    public var visibleFrameLessInset: CGRect {
        visibleFrame.inset(by: contentInset)
    }

    public var adjustedSize: CGSize {
        bounds.size.inset(by: adjustedContentInset)
    }

    public var offsetFrame: CGRect {
        let inset = adjustedContentInset
        return CGRect(
            x: -inset.left,
            y: -inset.top,
            width: max(0, contentSize.width - bounds.width + inset.right + inset.left),
            height: max(0, contentSize.height - bounds.height + inset.bottom + inset.top)
        )
    }

    public func absoluteLocation(for point: CGPoint) -> CGPoint {
        point - contentOffset
    }

    public func scrollTo(edge: UIRectEdge, animated: Bool) {
        let target: CGPoint
        switch edge {
        case UIRectEdge.top:
            target = CGPoint(x: contentOffset.x, y: offsetFrame.minY)
        case UIRectEdge.bottom:
            target = CGPoint(x: contentOffset.x, y: offsetFrame.maxY)
        case UIRectEdge.left:
            target = CGPoint(x: offsetFrame.minX, y: contentOffset.y)
        case UIRectEdge.right:
            target = CGPoint(x: offsetFrame.maxX, y: contentOffset.y)
        default:
            return
        }
        setContentOffset(target, animated: animated)
    }
}
