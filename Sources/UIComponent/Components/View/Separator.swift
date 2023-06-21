//  Created by Luke Zhao on 8/24/20.

import UIKit

public struct Separator: ComponentBuilder {
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

    public func build() -> some Component {
        ViewComponent<UIView>().backgroundColor(color)
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
