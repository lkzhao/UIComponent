//  Created by Luke Zhao on 8/23/20.

import Foundation

public protocol ComponentBuilder: Component {
    func build() -> Component
}

extension ComponentBuilder {
    public func layout(_ constraint: Constraint) -> any RenderNode {
        build().layout(constraint)
    }
}
