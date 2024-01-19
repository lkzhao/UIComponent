//  Created by Luke Zhao on 8/23/20.

import Foundation

@available(*, deprecated, message: "Please use for-in loop instead")
public struct ForEach<S: Sequence, D>: ComponentArrayContainer where S.Element == D {
    public let components: [any Component]

    public init(_ data: S, @ComponentArrayBuilder _ content: (D) -> [any Component]) {
        components = data.flatMap { content($0) }
    }
}
