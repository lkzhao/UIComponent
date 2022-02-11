//  Created by Luke Zhao on 8/24/20.

import UIKit

@available(iOS 13.0, *)
public struct Separator: ViewComponentBuilder {
  public static var defaultSeparatorColor: UIColor = {
    if #available(iOS 13, *) {
      return UIColor.separator
    } else {
      return UIColor.lightGray
    }
  }()

  public let color: UIColor

  public init(color: UIColor = Separator.defaultSeparatorColor) {
    self.color = color
  }
    
 /// The keyword some is only supported by iOS13. Is there any other solution?
  public func build() -> ConstraintOverrideViewComponent<ViewKeyPathUpdateComponent<SimpleViewComponent<UIView>, UIColor?>> {
    SimpleViewComponent<UIView>().backgroundColor(color)
      .constraint { constraint in
        if constraint.minSize.height <= 0, constraint.maxSize.width != .infinity {
          let size = CGSize(width: constraint.maxSize.width, height: 1 / UIScreen.main.scale)
          return Constraint(minSize: size, maxSize: size)
        } else if constraint.minSize.width <= 0, constraint.maxSize.height != .infinity {
          let size = CGSize(width: 1 / UIScreen.main.scale, height: constraint.maxSize.height)
          return Constraint(minSize: size, maxSize: size)
        }
        return constraint
      }
  }
}
