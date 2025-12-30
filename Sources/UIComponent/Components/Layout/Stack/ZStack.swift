//  Created by Luke Zhao on 8/26/20.


/// A container view that layers its children on top of each other.
public struct ZStack: Component {
    /// The vertical alignment of children within the ZStack.
    public var verticalAlignment: CrossAxisAlignment = .center
    /// The horizontal alignment of children within the ZStack.
    public var horizontalAlignment: CrossAxisAlignment = .center
    /// An array of components that the ZStack will layout.
    public var children: [any Component]

    /// Initializes a new ZStack with the specified alignment and children.
    /// - Parameters:
    ///   - verticalAlignment: The vertical alignment of children within the ZStack.
    ///   - horizontalAlignment: The horizontal alignment of children within the ZStack.
    ///   - children: An array of components that the ZStack will layout.
    public init(verticalAlignment: CrossAxisAlignment, horizontalAlignment: CrossAxisAlignment, children: [any Component]) {
        self.verticalAlignment = verticalAlignment
        self.horizontalAlignment = horizontalAlignment
        self.children = children
    }
    public func layout(_ constraint: Constraint) -> some RenderNode {
        var renderNodes: [any RenderNode] = children.map {
            $0.layout(Constraint(maxSize: constraint.maxSize))
        }
        let size = CGSize(
            width: renderNodes.max { $0.size.width < $1.size.width }?.size.width ?? 0,
            height: renderNodes.max { $0.size.height < $1.size.height }?.size.height ?? 0
        )
        .bound(to: constraint)
        let positions: [CGPoint] = renderNodes.enumerated()
            .map { (idx, node) in
                var result = CGRect(origin: .zero, size: node.size)
                switch verticalAlignment {
                case .start, .baselineFirst:
                    result.origin.y = 0
                case .center:
                    result.origin.y = (size.height - node.size.height) / 2
                case .end, .baselineLast:
                    result.origin.y = size.height - node.size.height
                case .stretch:
                    result.size.height = size.height
                }
                switch horizontalAlignment {
                case .start, .baselineFirst:
                    result.origin.x = 0
                case .center:
                    result.origin.x = (size.width - node.size.width) / 2
                case .end, .baselineLast:
                    result.origin.x = size.width - node.size.width
                case .stretch:
                    result.size.width = size.width
                }
                if node.size != result.size {
                    renderNodes[idx] = children[idx].layout(Constraint(tightSize: result.size))
                }
                return result.origin
            }
        return SlowRenderNode(size: size, children: renderNodes, positions: positions)
    }
}

extension ZStack {
    /// Initializes a new ZStack with the specified alignments and child components.
    /// - Parameters:
    ///   - verticalAlignment: The vertical alignment of children within the ZStack. Defaults to `.center`.
    ///   - horizontalAlignment: The horizontal alignment of children within the ZStack. Defaults to `.center`.
    ///   - content: A result builder closure that returns the child components to be laid out in the ZStack.
    public init(
        verticalAlignment: CrossAxisAlignment = .center,
        horizontalAlignment: CrossAxisAlignment = .center,
        @ComponentArrayBuilder _ content: () -> [any Component]
    ) {
        self.init(verticalAlignment: verticalAlignment, horizontalAlignment: horizontalAlignment, children: content())
    }
}
