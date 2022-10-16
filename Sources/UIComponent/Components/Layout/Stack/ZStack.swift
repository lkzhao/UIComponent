//  Created by Luke Zhao on 8/26/20.

@_implementationOnly import BaseToolbox
import UIKit

public struct ZStack: Component {
    public var verticalAlignment: CrossAxisAlignment = .center
    public var horizontalAlignment: CrossAxisAlignment = .center
    public var children: [Component]

    public func layout(_ constraint: Constraint) -> RenderNode {
        var renderNodes: [RenderNode] = children.map {
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
                case .start:
                    result.origin.y = 0
                case .center:
                    result.origin.y = (size.height - node.size.height) / 2
                case .end:
                    result.origin.y = size.height - node.size.height
                case .stretch:
                    result.size.height = size.height
                }
                switch horizontalAlignment {
                case .start:
                    result.origin.x = 0
                case .center:
                    result.origin.x = (size.width - node.size.width) / 2
                case .end:
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
    public init(
        verticalAlignment: CrossAxisAlignment = .center,
        horizontalAlignment: CrossAxisAlignment = .center,
        @ComponentArrayBuilder _ content: () -> [Component]
    ) {
        self.init(verticalAlignment: verticalAlignment, horizontalAlignment: horizontalAlignment, children: content())
    }
}
