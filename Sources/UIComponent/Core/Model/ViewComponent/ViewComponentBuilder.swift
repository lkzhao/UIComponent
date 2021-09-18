//  Created by Luke Zhao on 6/12/21.

import Foundation

public protocol ViewComponentBuilder: ViewComponent {
  associatedtype Content: ViewComponent
  func build() -> Content
}

extension ViewComponentBuilder {
  public func layout(_ constraint: Constraint) -> Content.R {
    build().layout(constraint)
  }
}
