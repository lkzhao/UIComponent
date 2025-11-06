//
//  Code.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/4/25.
//

struct Code: ComponentBuilder {
    let code: String
    init(_ code: String) {
        self.code = code
    }
    init(_ codeBlock: () -> String) {
        self.code = codeBlock()
    }
    func build() -> some Component {
        CodeComponent(code).inset(h: 16, v: 10)
            .backgroundColor(.systemGray.withAlphaComponent(0.1))
            .cornerRadius(10.0)
            .cornerCurve(.continuous)
            .borderWidth(0.5)
            .borderColor(UIColor.separator)
            .clipsToBounds(true)
    }
}
