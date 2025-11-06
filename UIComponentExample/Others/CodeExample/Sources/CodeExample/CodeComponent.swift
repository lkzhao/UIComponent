//
//  CodeComponent.swift
//  CodeExample
//
//  Created by Luke Zhao on 11/4/25.
//

import UIComponent

public struct CodeComponent: Component {
    let code: String
    public init(_ code: String) {
        self.code = code
    }
    public init(_ codeBlock: () -> String) {
        self.code = codeBlock()
    }
    public func layout(_ constraint: Constraint) -> some RenderNode {
        sizingTextView.code = code
        let size = sizingTextView.sizeThatFits(constraint.maxSize)
        return ViewComponent<CodeTextView>().code(code).size(size).inset(-4).layout(constraint)
    }
}
