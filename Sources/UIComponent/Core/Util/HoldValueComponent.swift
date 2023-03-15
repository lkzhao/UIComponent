//
//  File.swift
//  
//
//  Created by Luke Zhao on 3/14/23.
//

import Foundation

struct HoldValueComponent: Component {
    let child: Component
    let value: Any
    func layout(_ constraint: Constraint) -> RenderNode {
        HoldValueRenderNode(child: child.layout(constraint), value: value)
    }
}

struct HoldValueRenderNode: WrapperRenderNode {
    let child: RenderNode
    let value: Any?
}
