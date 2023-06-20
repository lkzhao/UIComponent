//  Created by Luke Zhao on 8/22/20.

import Foundation

@dynamicMemberLookup
public protocol ViewComponent<R>: Component {
    associatedtype R: RenderNode
    func layout(_ constraint: Constraint) -> R
}

extension ViewComponent {
    public func layout(_ constraint: Constraint) -> any RenderNode {
        layout(constraint) as R
    }
}
