//
//  Block.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/4/25.
//

struct Block: ComponentBuilder {
    let text: String
    func build() -> some Component {
        Text(text, font: .subtitle).textColor(.white).blockBackground(color: .systemBlue)
    }
}

extension Component {
    func blockBackground(color: UIColor) -> some Component {
        background {
            Space().fill()
                .with(\.layer.cornerRadius, 16)
                .with(\.layer.cornerCurve, .continuous)
                .with(\.layer.borderWidth, 2)
                .with(\.layer.borderColor, color.cgColor)
                .backgroundColor(color.withAlphaComponent(0.2))
        }
    }
}
