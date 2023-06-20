//  Created by Luke Zhao on 8/22/20.

import Foundation

@dynamicMemberLookup
public protocol Component<R> {
    associatedtype R: RenderNode
    func layout(_ constraint: Constraint) -> R
}
