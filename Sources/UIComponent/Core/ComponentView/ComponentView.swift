//  Created by Luke Zhao on 8/27/20.

import UIKit

/// A UIView that can render components
///
/// You can set the ``component`` property with your component tree for it to render
/// The render happens on the next layout cycle. But you can call ``reloadData`` to force it to render.
///
/// Most of the code is written in ``ComponentDisplayableView``, since both ``ComponentView``
/// and ``ComponentScrollView`` supports rendering components.
///
/// See ``ComponentDisplayableView`` for usage details.
open class ComponentView: UIView, ComponentDisplayableView {
    /// The `ComponentEngine` that handles layout logic for the `ComponentView`.
    lazy public var engine: ComponentEngine = ComponentEngine(view: self)

    /// Overrides the `layoutSubviews` method to integrate the component engine's layout logic.
    open override func layoutSubviews() {
        super.layoutSubviews()
        engine.layoutSubview()
    }

    /// Overrides the `sizeThatFits` method to calculate the size of the view based on the component engine.
    /// - Parameter size: The size constraint to consider for the view.
    /// - Returns: The preferred size of the view within the given constraints.
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        engine.sizeThatFits(size)
    }
}
