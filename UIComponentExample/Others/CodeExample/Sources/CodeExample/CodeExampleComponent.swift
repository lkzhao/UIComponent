//  Created by Luke Zhao on 11/4/25.

import UIComponent

public struct CodeExampleComponent: Component {
    public enum Style {
        case `default`
        case noInset
        case noWrap
    }
    let content: any Component
    let code: String
    let style: Style

    public init(content: any Component, code: String, style: Style = .default) {
        self.content = content
        self.code = code
        self.style = style
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        switch style {
        case .default:
            VStack(spacing: 4) {
                content.inset(16).view().codeBlockStyle()
                CodeComponent(code).inset(h: 16, v: 10).view().codeBlockStyle()
            }.layout(constraint)
        case .noInset:
            VStack(spacing: 4) {
                content.view().codeBlockStyle()
                CodeComponent(code).inset(h: 16, v: 10).view().codeBlockStyle()
            }.layout(constraint)
        case .noWrap:
            VStack(spacing: 4) {
                content.codeBlockStyle()
                CodeComponent(code).inset(h: 16, v: 10).view().codeBlockStyle()
            }.layout(constraint)
        }
    }
}

public extension Component {
    func codeBlockStyle(backgroundColor: PlatformColor = {
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        UIColor.systemGray.withAlphaComponent(0.1)
#elseif os(macOS)
        NSColor.systemGray.withAlphaComponent(0.1)
#else
        PlatformColor.clear
#endif
    }()) -> any Component {
        self.backgroundColor(backgroundColor)
            .cornerRadius(10.0)
            .cornerCurve(.continuous)
            .borderWidth(0.5)
            .borderColor({
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
                UIColor.separator
#elseif os(macOS)
                NSColor.separatorColor
#else
                nil
#endif
            }())
            .clipsToBounds(true)
    }
}
