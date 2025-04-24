//  Created by Luke Zhao on 8/23/20.

import UIKit

/// An enumeration that defines different strategies for sizing elements.
/// - `fill`: The element should expand to fill the available space.
/// - `fit`: The element should be contained within the available space, but fit to its own size.
/// - `absolute`: The element should be sized to an absolute value in points.
/// - `percentage`: The element should be sized relative to its parent, based on a percentage.
/// - `aspectPercentage`: The element should be sized based on a percentage of its intrinsic aspect ratio.
public enum SizeStrategy {
    case fill
    case fit
    case absolute(CGFloat)
    case percentage(CGFloat)
    case aspectPercentage(CGFloat)
}

/// A protocol defining methods for transforming constraints and adjusting sizes.
public protocol ConstraintTransformer {
    /// Calculates a new `Constraint` based on the given `constraint`.
    /// - Parameter constraint: The original `Constraint` to be transformed.
    /// - Returns: A new `Constraint` that has been transformed.
    func calculate(_ constraint: Constraint) -> Constraint
    
    /// Adjusts the given `size` to fit within the bounds of the `constraint`.
    /// - Parameters:
    ///   - size: The original `CGSize` to be adjusted.
    ///   - constraint: The `Constraint` within which the `size` must fit.
    /// - Returns: A new `CGSize` that fits within the `constraint`.
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

/// A component that overrides the constraints of its content component.
/// It uses a `ConstraintTransformer` to calculate the final constraints that will be applied to the content.
public struct ConstraintOverrideComponent<Content: Component>: Component {
    /// The content component that will be affected by the `ConstraintTransformer`.
    public let content: Content
    /// The transformer used to calculate and apply constraints to the `content` component.
    public let transformer: ConstraintTransformer

    /// Initializes a `ConstraintOverrideComponent` with a given content component and a constraint transformer.
    /// - Parameters:
    ///   - content: The content component that will be affected by the constraint transformations.
    ///   - transformer: The `ConstraintTransformer` that will be used to calculate and apply constraints to the content component.
    init(content: Content, transformer: ConstraintTransformer) {
        self.content = content
        self.transformer = transformer
    }

    public func layout(_ constraint: Constraint) -> AnyRenderNodeOfView<Content.R.View> {
        let finalConstraint = transformer.calculate(constraint)
//        if finalConstraint.isTight {
//            return LazyRenderNode(component: content, environmentValues: EnvironmentValues.current, size: finalConstraint.minSize).eraseToAnyRenderNodeOfView()
//        } else {
            let renderNode = content.layout(finalConstraint)
            return SizeOverrideRenderNode(content: renderNode, size: transformer.bound(size: renderNode.size, to: finalConstraint)).eraseToAnyRenderNodeOfView()
//        }
    }
}

/// A render node wrapper that overrides the size of its content.
/// It contains the original content render node and the size that should be applied to it.
public struct SizeOverrideRenderNode<Content: RenderNode>: RenderNodeWrapper {
    public let content: Content
    public let size: CGSize

    /// Initializes a `SizeOverrideRenderNode` with a given content render node and a specific size.
    /// - Parameters:
    ///   - content: The content render node whose size will be overridden.
    ///   - size: The new size to apply to the content render node.
    public init(content: Content, size: CGSize) {
        self.content = content
        self.size = size
    }
}

public class LazyRenderNode<Content: Component>: RenderNodeWrapper {
    public let component: Content
    private var _content: Content.R?
    public var content: Content.R {
        if _content == nil {
            EnvironmentValues.saveCurrentValues()
            EnvironmentValues.current = environmentValues
            _content = component.layout(.init(tightSize: size))
            EnvironmentValues.restoreCurrentValues()
        }
        return _content!
    }
    public var didLayout: Bool {
        _content != nil
    }
    public let size: CGSize
    let environmentValues: EnvironmentValues
    init(component: Content, environmentValues: EnvironmentValues, size: CGSize) {
        self.component = component
        self.environmentValues = environmentValues
        self.size = size
    }
}
