//  Created by Luke Zhao on 8/22/20.

import Foundation

@dynamicMemberLookup
public protocol ViewComponent: Component {
    associatedtype R: ViewRenderNode
    func layout(_ constraint: Constraint) -> R
}

extension ViewComponent {
    public func layout(_ constraint: Constraint) -> RenderNode {
        layout(constraint) as R
    }
}
