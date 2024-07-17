//  Created by Luke Zhao on 8/19/21.

import UIKit

/// `WrapperAnimator` is a subclass of `Animator` that allows for additional
/// animation handling by providing custom blocks for insert, update, and delete operations.
/// It can also pass through these update operation to another animator if needed.
public struct WrapperAnimator: Animator {
    /// The underlying animator that can be used to perform animations along side the custom animation blocks.
    public var content: Animator?
    /// Determines whether the `WrapperAnimator` should pass the update operation to the underlying `content` animator after executing `updateBlock`.
    public var passthroughUpdate: Bool = false
    /// A block that is executed when a new view is inserted. If `nil`, the insert operation is passed to the underlying `content` animator.
    public var insertBlock: ((UIView, UIView, CGRect) -> Void)?
    /// A block that is executed when a view needs to be updated. If `nil`, the update operation is passed to the underlying `content` animator.
    public var updateBlock: ((UIView, UIView, CGRect) -> Void)?
    /// A block that is executed when a view is deleted. If `nil`, the delete operation is passed to the underlying `content` animator.
    public var deleteBlock: ((UIView, UIView, @escaping () -> Void) -> Void)?

    public func shift(hostingView: UIView, delta: CGPoint, view: UIView) {
        (content ?? hostingView.componentEngine.animator).shift(
            hostingView: hostingView,
            delta: delta,
            view: view
        )
    }

    public func update(hostingView: UIView, view: UIView, frame: CGRect) {
        if let updateBlock {
            updateBlock(hostingView, view, frame)
            if passthroughUpdate {
                (content ?? hostingView.componentEngine.animator).update(hostingView: hostingView, view: view, frame: frame)
            }
        } else {
            (content ?? hostingView.componentEngine.animator).update(hostingView: hostingView, view: view, frame: frame)
        }
    }

    public func insert(hostingView: UIView, view: UIView, frame: CGRect) {
        if let insertBlock {
            insertBlock(hostingView, view, frame)
        } else {
            (content ?? hostingView.componentEngine.animator).insert(hostingView: hostingView, view: view, frame: frame)
        }
    }

    public func delete(hostingView: UIView, view: UIView, completion: @escaping () -> Void) {
        if let deleteBlock {
            deleteBlock(hostingView, view, completion)
        } else {
            (content ?? hostingView.componentEngine.animator).delete(hostingView: hostingView, view: view, completion: completion)
        }
    }
}
