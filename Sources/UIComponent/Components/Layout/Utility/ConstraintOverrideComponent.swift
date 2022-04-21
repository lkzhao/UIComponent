//  Created by Luke Zhao on 8/23/20.

import UIKit

public enum SizeStrategy {
    case fill, fit
    case absolute(CGFloat)
    case percentage(CGFloat)
    case aspectPercentage(CGFloat)
}

public protocol ConstraintTransformer {
    func calculate(_ constraint: Constraint) -> Constraint
    func bound(size: CGSize, to constraint: Constraint) -> CGSize
}

extension ConstraintTransformer {
    public func bound(size: CGSize, to constraint: Constraint) -> CGSize {
        size.bound(to: constraint)
    }
}

struct BlockConstraintTransformer: ConstraintTransformer {
    let block: (Constraint) -> Constraint
    func calculate(_ constraint: Constraint) -> Constraint {
        block(constraint)
    }
}

struct PassThroughConstraintTransformer: ConstraintTransformer {
    let constraint: Constraint
    func calculate(_ constraint: Constraint) -> Constraint {
        self.constraint
    }
}

struct SizeStrategyConstraintTransformer: ConstraintTransformer {
    let width: SizeStrategy
    let height: SizeStrategy
    func calculate(_ constraint: Constraint) -> Constraint {
        var maxSize = constraint.maxSize
        var minSize = constraint.minSize
        switch width {
        case .fill:
            if maxSize.width != .infinity {
                minSize.width = maxSize.width
            }
        case .fit:
            break
        case .absolute(let value):
            assert(value >= 0, "absolute value should be greater than 0")
            maxSize.width = value
            minSize.width = value
        case .percentage(let value):
            let maxWidth = maxSize.width
            if maxWidth != .infinity {
                maxSize.width = value * maxWidth
                minSize.width = value * maxWidth
            }
        case .aspectPercentage(let value):
            if case .absolute(let height) = height {
                maxSize.width = value * height
                minSize.width = value * height
            } else if maxSize.height != .infinity {
                maxSize.width = value * maxSize.height
                minSize.width = value * maxSize.height
            }
        }
        switch height {
        case .fill:
            if maxSize.height != .infinity {
                minSize.height = maxSize.height
            }
        case .fit:
            break
        case .absolute(let value):
            assert(value >= 0, "absolute value should be greater than 0")
            maxSize.height = value
            minSize.height = value
        case .percentage(let value):
            let maxHeight = maxSize.height
            if maxHeight != .infinity {
                maxSize.height = value * maxHeight
                minSize.height = value * maxHeight
            }
        case .aspectPercentage(let value):
            if case .absolute(let width) = width {
                maxSize.height = value * width
                minSize.height = value * width
            } else if maxSize.width != .infinity {
                maxSize.height = value * maxSize.width
                minSize.height = value * maxSize.width
            }
        }
        return Constraint(minSize: minSize, maxSize: maxSize)
    }

    func bound(size: CGSize, to constraint: Constraint) -> CGSize {
        var boundSize = size.bound(to: constraint)
        // if size strategy is fit, we don't force the size component to be bound to the constraint
        // this is useful for VStack and HStack to have intrisic width/height even when a size modifier
        // is applied to them.
        // e.g.
        //   HStack {
        //     ...
        //   }.size(height: 44)
        // will have unlimited width, but height will be locked at 44
        if case .fit = width {
            boundSize.width = size.width
        }
        if case .fit = height {
            boundSize.height = size.height
        }
        return boundSize
    }
}

struct SizeOverrideRenderNode: RenderNode {
    let child: RenderNode
    let size: CGSize
    var children: [RenderNode] {
        [child]
    }
    var positions: [CGPoint] {
        [.zero]
    }
}

struct ConstraintOverrideComponent: Component {
    let child: Component
    let transformer: ConstraintTransformer
    func layout(_ constraint: Constraint) -> RenderNode {
        let finalConstraint = transformer.calculate(constraint)
        let renderNode = child.layout(finalConstraint)
        return SizeOverrideRenderNode(child: renderNode, size: transformer.bound(size: renderNode.size, to: finalConstraint))
    }
}

public struct ConstraintOverrideViewComponent<Content: ViewComponent>: ViewComponent {
    let child: Content
    let transformer: ConstraintTransformer
    public func layout(_ constraint: Constraint) -> Content.R {
        child.layout(transformer.calculate(constraint))
    }
}
