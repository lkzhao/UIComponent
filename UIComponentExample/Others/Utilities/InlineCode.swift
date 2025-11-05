//
//  InlineCode.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/4/25.
//

struct InlineCode: ComponentBuilder {
    let code: String
    init(_ code: String) {
        self.code = code
    }
    init(_ codeBlock: () -> String) {
        self.code = codeBlock()
    }
    func build() -> some Component {
        CodeComponent(code).inset(h: 6, v: 4)
            .backgroundColor(.secondarySystemBackground)
            .cornerRadius(10.0)
            .cornerCurve(.continuous)
            .borderWidth(0.5)
            .borderColor(UIColor.separator)
            .clipsToBounds(true)
            .inset(v: -6)
    }
}
