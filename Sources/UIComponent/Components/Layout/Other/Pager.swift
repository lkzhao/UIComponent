
import UIKit

/// A protocol that defines the properties and behaviors of a pager component.
/// A pager is responsible for laying out a series of components in a swipeable full screen pager format.
public protocol Pager: BaseLayoutProtocol {
    /// Defines how child components are aligned along the cross axis.
    var alignItems: CrossAxisAlignment { get }
    /// An array of components that the pager will manage and layout.
    var children: [any Component] { get }
}

extension Pager {
    public func layout(_ constraint: Constraint) -> R {
        let isUnbounded = main(constraint.maxSize) == .infinity
        guard !isUnbounded else {
            let error = "Pager cannot be wrapped under an unlimited constraint component on its main axis. e.g. under a HStack or VStack"
            assertionFailure(error)
            let child = Text(error).textColor(.red)
            let childNode = child.layout(constraint)
            return renderNode(size: childNode.size, children: [childNode], positions: [.zero])
        }
        let pageMain = main(constraint.maxSize)
        let childConstraint = Constraint(minSize: size(main: pageMain, cross: cross(constraint.minSize)),
                                         maxSize: size(main: pageMain, cross: cross(constraint.maxSize)))
        var renderNodes: [any RenderNode] = []
        var crossMax: CGFloat = 0
        for child in children {
            let node = child.layout(childConstraint)
            renderNodes.append(node)
            crossMax = max(cross(node.size), crossMax)
        }
        var positions: [CGPoint] = []
        for (index, child) in renderNodes.enumerated() {
            var crossValue: CGFloat = 0
            switch alignItems {
            case .start, .stretch, .baselineFirst:
                crossValue = 0
            case .end, .baselineLast:
                crossValue = crossMax - cross(child.size)
            case .center:
                crossValue = (crossMax - cross(child.size)) / 2
            }
            positions.append(point(main: CGFloat(index) * pageMain, cross: crossValue))
        }
        return renderNode(size: size(main: CGFloat(children.count) * pageMain, cross: crossMax), children: renderNodes, positions: positions)
    }
}

/// A horizontal pager component that lays out its children in a horizontal swipeable pager format.
public struct HPager: Component, Pager, HorizontalLayoutProtocol {
    /// Defines how child components are aligned along the cross axis.
    public let alignItems: CrossAxisAlignment
    /// An array of components that the pager will manage and layout.
    public let children: [any Component]
    
    /// Initializes a new horizontal pager with alignment and children.
    /// - Parameters:
    ///   - alignItems: The alignment of children along the cross axis. Defaults to `.start`.
    ///   - children: An array of components to be laid out in the pager. Defaults to an empty array.
    public init(alignItems: CrossAxisAlignment = .start, children: [any Component] = []) {
        self.alignItems = alignItems
        self.children = children
    }
}

extension HPager {
    /// Initializes a new horizontal pager with alignment and a result builder for children components.
    /// - Parameters:
    ///   - alignItems: The alignment of children along the cross axis. Defaults to `.start`.
    ///   - content: A result builder closure that returns an array of components to be laid out in the pager.
    public init(alignItems: CrossAxisAlignment = .start, @ComponentArrayBuilder _ content: () -> [any Component]) {
        self.init(alignItems: alignItems, children: content())
    }
}

/// A vertical pager component that lays out its children in a vertical swipeable pager format.
public struct VPager: Component, Pager, VerticalLayoutProtocol {
    /// Defines how child components are aligned along the cross axis.
    public let alignItems: CrossAxisAlignment
    /// An array of components that the pager will manage and layout.
    public let children: [any Component]
    
    /// Initializes a new vertical pager with alignment and children.
    /// - Parameters:
    ///   - alignItems: The alignment of children along the cross axis. Defaults to `.start`.
    ///   - children: An array of components to be laid out in the pager. Defaults to an empty array.
    public init(alignItems: CrossAxisAlignment = .start, children: [any Component] = []) {
        self.alignItems = alignItems
        self.children = children
    }
}

extension VPager {
    /// Initializes a new vertical pager with alignment and a result builder for children components.
    /// - Parameters:
    ///   - alignItems: The alignment of children along the cross axis. Defaults to `.start`.
    ///   - content: A result builder closure that returns an array of components to be laid out in the pager.
    public init(alignItems: CrossAxisAlignment = .start, @ComponentArrayBuilder _ content: () -> [any Component]) {
        self.init(alignItems: alignItems, children: content())
    }
}

