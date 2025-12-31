//  Created by Luke Zhao on 11/4/25.

import UIComponent

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
private let sizingTextView = CodeTextView()
#endif

public struct CodeComponent: Component {
    let code: String
    public init(_ code: String) {
        self.code = code
    }
    public init(_ codeBlock: () -> String) {
        self.code = codeBlock()
    }
    public func layout(_ constraint: Constraint) -> some RenderNode {
        let size: CGSize
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        sizingTextView.code = code
        size = sizingTextView.sizeThatFits(constraint.maxSize)
#elseif os(macOS)
        size = CodeTextView.sizeThatFits(code: code, in: constraint.maxSize)
#else
        size = .zero
#endif
        return ViewComponent<CodeTextView>().code(code).size(size).inset(-4).layout(constraint)
    }
}
