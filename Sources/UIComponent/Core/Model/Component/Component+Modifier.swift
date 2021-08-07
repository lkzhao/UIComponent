//  Created by Luke Zhao on 8/5/21.

import UIKit

public extension Component {
  func `if`(_ value: Bool, apply: (Self) -> Component) -> Component {
    value ? apply(self) : self
  }
}

public extension Component {
  func view() -> ComponentViewComponent<ComponentView> {
    ComponentViewComponent(component: self)
  }

  func scrollView() -> ComponentViewComponent<ComponentScrollView> {
    ComponentViewComponent(component: self)
  }
}

public extension Component {
  func background(_ component: Component) -> Background {
    Background(child: self, background: component)
  }
  func background(_ component: () -> Component) -> Background {
    Background(child: self, background: component())
  }
}

public extension Component {
  func overlay(_ component: Component) -> Overlay {
    Overlay(child: self, overlay: component)
  }
  func overlay(_ component: () -> Component) -> Overlay {
    Overlay(child: self, overlay: component())
  }
}

public extension Component {
  func badge(_ component: Component,
             verticalAlignment: CrossAxisAlignment = .start,
             horizontalAlignment: CrossAxisAlignment = .end,
             offset: CGVector = .zero) -> Badge {
    Badge(child: self,
          overlay: component,
          verticalAlignment: verticalAlignment,
          horizontalAlignment: horizontalAlignment,
          offset: offset)
  }
  func badge(verticalAlignment: CrossAxisAlignment = .start,
             horizontalAlignment: CrossAxisAlignment = .end,
             offset: CGVector = .zero,
             _ component: () -> Component) -> Badge {
    Badge(child: self,
          overlay: component(),
          verticalAlignment: verticalAlignment,
          horizontalAlignment: horizontalAlignment,
          offset: offset)
  }
}

public extension Component {
  func flex(_ flex: CGFloat = 1, alignSelf: CrossAxisAlignment? = nil) -> Flexible {
    Flexible(flex: flex, alignSelf: alignSelf, child: self)
  }
}
