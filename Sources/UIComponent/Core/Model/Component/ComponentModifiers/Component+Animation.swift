/// A component produced by ``Component/animateInsert(_:)``, ``Component/animateUpdate(passthrough:_:)``, & ``Component/animateDelete(_:)`` modifiers
public typealias AnimatorWrapperComponent<Content: Component> = ModifierComponent<Content, AnimatorWrapperRenderNode<Content.R>>

extension Component {
    /// Animates layout update to the component (frame change).
    /// - Parameters:
    ///   - value: A Boolean value that determines whether the layout update should be animated.
    ///   - passthrough: A Boolean value that determines whether the animator update method will be called for the content component.
    ///   - updateBlock: A closure that is called to perform the layout update animation.
    /// - Returns: An `AnimatorWrapperComponent` containing the modified component.
    public func animateUpdateIf(
        _ value: Bool,
        passthrough: Bool = false,
        _ updateBlock: @escaping ((UIView, UIView, CGRect) -> Void)
    ) -> some Component {
        animateUpdate(passthrough: passthrough) { hostingView, view, frame in
            if value {
                updateBlock(hostingView, view, frame)
            } else {
                view.frameWithoutTransform = frame
            }
        }
    }

    /// Animates layout update to the component (frame change).
    /// - Parameters:
    ///   - passthrough: A Boolean value that determines whether the animator update method will be called for the content component.
    ///   - updateBlock: A closure that is called to perform the layout update animation.
    /// - Returns: An `AnimatorWrapperComponent` containing the modified component.
    public func animateUpdate(passthrough: Bool = false, _ updateBlock: @escaping ((UIView, UIView, CGRect) -> Void)) -> AnimatorWrapperComponent<Self> {
        ModifierComponent(content: self) {
            $0.animateUpdate(passthrough: passthrough, updateBlock)
        }
    }

    /// Animates the insertion of the component.
    /// - Parameter insertBlock: A closure that is called to perform the insertion animation.
    /// - Returns: An `AnimatorWrapperComponent` containing the modified component.
    public func animateInsert(_ insertBlock: @escaping ((UIView, UIView, CGRect) -> Void)) -> AnimatorWrapperComponent<Self> {
        ModifierComponent(content: self) {
            $0.animateInsert(insertBlock)
        }
    }

    /// Animates the deletion of the component.
    /// - Parameter deleteBlock: A closure that is called to perform the deletion animation.
    /// - Returns: An `AnimatorWrapperComponent` containing the modified component.
    public func animateDelete(_ deleteBlock: @escaping (UIView, UIView, @escaping () -> Void) -> Void) -> AnimatorWrapperComponent<Self> {
        ModifierComponent(content: self) {
            $0.animateDelete(deleteBlock)
        }
    }
}
