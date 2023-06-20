//  Created by Luke Zhao on 8/6/21.

import UIKit

public struct VStack: Component, Stack, VerticalLayoutProtocol {
    public let spacing: CGFloat
    public let justifyContent: MainAxisAlignment
    public let alignItems: CrossAxisAlignment
    public let children: [any Component]
    public init(
        spacing: CGFloat = 0,
        justifyContent: MainAxisAlignment = .start,
        alignItems: CrossAxisAlignment = .start,
        children: [any Component] = []
    ) {
        self.spacing = spacing
        self.justifyContent = justifyContent
        self.alignItems = alignItems
        self.children = children
    }
}

extension VStack {
    public init(spacing: CGFloat = 0, justifyContent: MainAxisAlignment = .start, alignItems: CrossAxisAlignment = .start, @ComponentArrayBuilder _ content: () -> [any Component]) {
        self.init(
            spacing: spacing,
            justifyContent: justifyContent,
            alignItems: alignItems,
            children: content()
        )
    }
}
