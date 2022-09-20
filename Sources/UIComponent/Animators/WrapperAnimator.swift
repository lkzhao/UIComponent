//  Created by Luke Zhao on 8/19/21.

import UIKit

public class WrapperAnimator: Animator {
    public var content: Animator?
    public var passthrough: Bool = false
    public var insertBlock: ((ComponentDisplayableView, UIView, CGRect) -> Void)?
    public var updateBlock: ((ComponentDisplayableView, UIView, CGRect) -> Void)?
    public var deleteBlock: ((ComponentDisplayableView, UIView, () -> Void) -> Void)?

    public override func update(componentView: ComponentDisplayableView, view: UIView, frame: CGRect) {
        if let updateBlock {
            updateBlock(componentView, view, frame)
            if passthrough, let content = content {
                content.update(componentView: componentView, view: view, frame: frame)
            }
        } else if let content {
            content.update(componentView: componentView, view: view, frame: frame)
        } else {
            componentView.animator.update(componentView: componentView, view: view, frame: frame)
        }
    }

    public override func insert(componentView: ComponentDisplayableView, view: UIView, frame: CGRect) {
        if let insertBlock {
            insertBlock(componentView, view, frame)
        } else if let content {
            content.insert(componentView: componentView, view: view, frame: frame)
        } else {
            componentView.animator.insert(componentView: componentView, view: view, frame: frame)
        }
    }

    public override func delete(componentView: ComponentDisplayableView, view: UIView, completion: @escaping () -> Void) {
        if let deleteBlock {
            deleteBlock(componentView, view, completion)
        } else if let content {
            content.delete(componentView: componentView, view: view, completion: completion)
        } else {
            componentView.animator.delete(componentView: componentView, view: view, completion: completion)
        }
    }
}
