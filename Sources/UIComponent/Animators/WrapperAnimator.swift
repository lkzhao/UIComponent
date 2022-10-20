//  Created by Luke Zhao on 8/19/21.

import UIKit

public class WrapperAnimator: Animator {
    public var content: Animator?
    public var passthroughUpdate: Bool = false
    public var insertBlock: ((ComponentDisplayableView, UIView, CGRect) -> Void)?
    public var updateBlock: ((ComponentDisplayableView, UIView, CGRect) -> Void)?
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
