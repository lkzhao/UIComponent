//  Created by Luke Zhao on 8/23/20.

import Foundation

public protocol ComponentBuilder: Component {
    associatedtype ResultComponent: Component
    func build() -> ResultComponent
}

extension ComponentBuilder {
    public func layout(_ constraint: Constraint) -> ResultComponent.R {
        build().layout(constraint)
    }
}
