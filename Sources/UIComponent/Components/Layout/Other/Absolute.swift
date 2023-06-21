//  Created by Luke Zhao on 8/29/20.

import UIKit

/// # Absolute Component
///
/// Renders a list of child components base on the provided `children` and `frames` parameters.
public struct Absolute: Component {
    public var children: [any Component]
    public var frames: [CGRect]

    public init(children: [any Component], frames: [CGRect]) {
        self.children = children
        self.frames = frames
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let frame = frames.reduce(frames.first ?? .zero) {
            $0.union($1)
        }
        return SlowRenderNode(
            size: CGSize(width: frame.maxX, height: frame.maxY),
            children: zip(children, frames).map({ $0.0.layout(Constraint(tightSize: $0.1.size)) }),
            positions: frames.map({ $0.origin })
        )
    }
}
