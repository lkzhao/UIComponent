//  Created by y H on 2022/4/6.

import Popover
import UIComponent
import UIKit

extension PopoverManager {
  func popover(popoverComponentView: ComponentView = ComponentView(),
               sourceView: UIView,
               containerView: UIView,
               spacing: CGSize = CGSize(width: 5, height: 5),
               identifier: String? = nil)
  {
    var configer = PopoverConfig(container: containerView)
    configer.anchor = .view(view: sourceView)
    configer.showTriangle = false
    configer.backgroundColor = .clear
    configer.backgroundOverlayColor = .clear
    configer.shadowColor = .black
    configer.shadowRadius = 15
    configer.shadowOpacity = 0.1
    configer.shadowOffset = spacing
    configer.positioning.horizontalAlignment = .end
    configer.positioning.verticalAlignment = .after
    configer.positioning.spacing = spacing
    PopoverManager.shared.show(popover: popoverComponentView,
                               config: configer)
  }
}
