//
//  CodeExampleComponent.swift
//  CodeExample
//
//  Created by Luke Zhao on 11/4/25.
//

import UIComponent
import UIKit

let sizingTextView = CodeTextView()

public struct CodeExampleComponent: Component {
    let content: any Component
    let code: String
    let addInset: Bool

    public init(content: any Component, code: String, addInset: Bool = false) {
        self.content = content
        self.code = code
        self.addInset = addInset
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let wrappedContent: any Component = addInset ? content.inset(16) : content
        return VStack(spacing: 4) {
            wrappedContent.codeBlockStyle()
            CodeComponent(code).inset(h: 16, v: 10).codeBlockStyle()
        }
        .layout(constraint)
    }
}

public extension Component {
    func codeBlockStyle(backgroundColor: UIColor = .systemGray.withAlphaComponent(0.1)) -> any Component {
        self.view().backgroundColor(backgroundColor)
            .cornerRadius(10.0)
            .cornerCurve(.continuous)
            .borderWidth(0.5)
            .borderColor(UIColor.separator)
            .clipsToBounds(true)
    }
}
