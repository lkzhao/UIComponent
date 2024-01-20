//  Created by Luke Zhao on 8/19/21.

import UIKit

/// `WrapperAnimator` is a subclass of `Animator` that allows for additional
/// animation handling by providing custom blocks for insert, update, and delete operations.
/// It can also pass through these update operation to another animator if needed.
public class WrapperAnimator: Animator {
    /// The underlying animator that can be used to perform animations along side the custom animation blocks.
    public var content: Animator?
    /// Determines whether the `WrapperAnimator` should pass the update operation to the underlying `content` animator after executing `updateBlock`.
    public var passthroughUpdate: Bool = false
    /// A block that is executed when a new view is inserted. If `nil`, the insert operation is passed to the underlying `content` animator.
    public var insertBlock: ((ComponentDisplayableView, UIView, CGRect) -> Void)?
    /// A block that is executed when a view needs to be updated. If `nil`, the update operation is passed to the underlying `content` animator.
    public var updateBlock: ((ComponentDisplayableView, UIView, CGRect) -> Void)?
    /// A block that is executed when a view is deleted. If `nil`, the delete operation is passed to the underlying `content` animator.
    public var deleteBlock: ((ComponentDisplayableView, UIView, () -> Void) -> Void)?

    public override func shift(componentView: ComponentDisplayableView, delta: CGPoint, view: UIView) {
        (content ?? componentView.animator).shift(componentView: componentView, delta: delta, view: view)
    }

    public override func update(componentView: ComponentDisplayableView, view: UIView, frame: CGRect) {
        if let updateBlock {
            updateBlock(componentView, view, frame)
            if passthroughUpdate {
                (content ?? componentView.animator).update(componentView: componentView, view: view, frame: frame)
            }
        } else {
            (content ?? componentView.animator).update(componentView: componentView, view: view, frame: frame)
        }
    }

    public override func insert(componentView: ComponentDisplayableView, view: UIView, frame: CGRect) {
        if let insertBlock {
            insertBlock(componentView, view, frame)
        } else {
            (content ?? componentView.animator).insert(componentView: componentView, view: view, frame: frame)
        }
    }

    public override func delete(componentView: ComponentDisplayableView, view: UIView, completion: @escaping () -> Void) {
        if let deleteBlock {
            deleteBlock(componentView, view, completion)
        } else {
            (content ?? componentView.animator).delete(componentView: componentView, view: view, completion: completion)
        }
    }
}
