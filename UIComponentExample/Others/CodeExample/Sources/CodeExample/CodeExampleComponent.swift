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

    public init(content: any Component, code: String) {
        self.content = content
        self.code = code
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        VStack(spacing: 4) {
            content.codeBlockStyle(backgroundColor: .tertiarySystemBackground)
            CodeComponent(code).inset(h: 16, v: 10).codeBlockStyle()
        }
        .layout(constraint)
    }
}

public extension Component {
    func codeBlockStyle(backgroundColor: UIColor = .secondarySystemBackground) -> any Component {
        self.view().backgroundColor(backgroundColor)
            .cornerRadius(10.0)
            .cornerCurve(.continuous)
            .borderWidth(0.5)
            .borderColor(UIColor.separator)
            .clipsToBounds(true)
    }
}
