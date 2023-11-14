//  Created by Luke Zhao on 8/23/20.

import Foundation

public struct Join: ComponentArrayContainer {
    public let components: [any Component]

    public init(@ComponentArrayBuilder _ content: () -> [any Component], @ComponentArrayBuilder separator: () -> [any Component]) {
        var result: [any Component] = []
        let components = content()
        for i in 0..<components.count - 1 {
            result.append(components[i])
            result.append(contentsOf: separator())
        }
        if let lastComponent = components.last {
            result.append(lastComponent)
        }
        self.components = result
    }
}
