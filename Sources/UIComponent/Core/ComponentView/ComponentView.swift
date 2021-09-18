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
  lazy public var engine: ComponentEngine = ComponentEngine(view: self)

  open override func safeAreaInsetsDidChange() {
    super.safeAreaInsetsDidChange()
    setNeedsInvalidateLayout()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    engine.layoutSubview()
  }

  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    engine.sizeThatFits(size)
  }
}
