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

    public func shift(componentView: UIView, delta: CGPoint, view: UIView) {
        (content ?? componentView.componentEngine.animator).shift(
            componentView: componentView,
            delta: delta,
            view: view
        )
    }

    public func update(componentView: UIView, view: UIView, frame: CGRect) {
        if let updateBlock {
            updateBlock(componentView, view, frame)
            if passthroughUpdate {
                (content ?? componentView.componentEngine.animator).update(componentView: componentView, view: view, frame: frame)
            }
        } else {
            (content ?? componentView.componentEngine.animator).update(componentView: componentView, view: view, frame: frame)
        }
    }

    public func insert(componentView: UIView, view: UIView, frame: CGRect) {
        if let insertBlock {
            insertBlock(componentView, view, frame)
        } else {
            (content ?? componentView.componentEngine.animator).insert(componentView: componentView, view: view, frame: frame)
        }
    }

    public func delete(componentView: UIView, view: UIView, completion: @escaping () -> Void) {
        if let deleteBlock {
            deleteBlock(componentView, view, completion)
        } else {
            (content ?? componentView.componentEngine.animator).delete(componentView: componentView, view: view, completion: completion)
        }
    }
}
