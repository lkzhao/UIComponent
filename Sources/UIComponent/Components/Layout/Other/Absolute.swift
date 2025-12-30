//  Created by Luke Zhao on 8/29/20.

/// A Component that renders a list of child components base on the provided `children` and `frames` parameters.
public struct Absolute: Component {
    /// The child components that the `Absolute` component will render.
    public var children: [any Component]

    /// The frames corresponding to each child component in `children`.
    public var frames: [CGRect]

    /// Initializes an `Absolute` component with a list of child components and their corresponding frames.
    /// - Parameters:
    ///   - children: An array of child components to be laid out absolutely.
    ///   - frames: An array of `CGRect` values that define the frame for each child component.
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
