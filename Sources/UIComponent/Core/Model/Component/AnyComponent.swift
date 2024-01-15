//
//  File.swift
//  
//
//  Created by Luke Zhao on 6/21/23.
//

import UIKit

public struct AnyComponent: Component {
    public let erasing: any Component
    public init(_ erasing: any Component) {
        self.erasing = erasing
    }
    public func layout(_ constraint: Constraint) -> AnyRenderNode {
        erasing.layout(constraint).eraseToAnyRenderNode()
    }
}

extension Component {
    public func eraseToAnyComponent() -> AnyComponent {
        AnyComponent(self)
    }
}
