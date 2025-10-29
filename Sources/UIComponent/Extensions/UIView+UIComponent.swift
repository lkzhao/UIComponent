//  Created by Luke Zhao on 2017-07-24.

import UIKit

extension UIView {
    private struct AssociatedKeys {
        static var ckContext = "ckContext"
    }

    internal var _ckContext: CKContext? {
        withUnsafePointer(to: &AssociatedKeys.ckContext) {
            objc_getAssociatedObject(self, $0) as? CKContext
        }
    }

    internal var ckContext: CKContext {
        if let context = _ckContext {
            return context
        }
        let context = CKContext()
        withUnsafePointer(to: &AssociatedKeys.ckContext) {
            objc_setAssociatedObject(self, $0, context, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return context
    }
}

@objc extension UIView {
    func recycleForUIComponentReuse() {
        if let _ckContext,
            let reuseIdentifier = _ckContext.reuseIdentifier,
            let reuseManager = _ckContext.reuseManager
        {
            reuseManager.enqueue(identifier: reuseIdentifier, view: self)
        } else {
            removeFromSuperview()
        }
    }
}

class CKContext {
    var reuseIdentifier: String?
    var reuseManager: ReuseManager?
}
