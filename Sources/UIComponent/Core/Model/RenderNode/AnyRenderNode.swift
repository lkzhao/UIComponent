//  Created by Luke Zhao on 8/22/20.

@_implementationOnly import BaseToolbox
import CoreGraphics
import Foundation
import UIKit

public protocol AnyRenderNode {
    /// size of the render node
    var size: CGSize { get }

    /// positions of child render nodes
    var positions: [CGPoint] { get }

    /// child render nodes
    var children: [AnyRenderNode] { get }

    /// Get indexes of the children that are visible in the given frame
    /// - Parameter frame: Parent component's visible frame in current component's coordinates.
    func visibleIndexes(in frame: CGRect) -> IndexSet

    /// Get renderables that are visible in the given frame
    /// - Parameter frame: Parent component's visible frame in current component's coordinates.
    ///
    /// The default implementation recursively retrives all Renderable from visible children and combines them
    func visibleRenderables(in frame: CGRect) -> [Renderable]
}

// MARK: - Default implementation

extension AnyRenderNode {
    public var children: [AnyRenderNode] { [] }
    public var positions: [CGPoint] { [] }

    public func visibleIndexes(in frame: CGRect) -> IndexSet {
        IndexSet(0..<children.count)
    }

    public func visibleRenderables(in frame: CGRect) -> [Renderable] {
        fatalError()
    }
}

extension AnyRenderNode {
    public func frame(at index: Int) -> CGRect? {
        guard let size = children.get(index)?.size, let position = positions.get(index) else { return nil }
        return CGRect(origin: position, size: size)
    }

    public func frame(id: String) -> CGRect? {
//        if let viewRenderNode = self as? (any ViewRenderNode), viewRenderNode.id == id {
//            return CGRect(origin: .zero, size: size)
//        }
//        for (index, child) in children.enumerated() {
//            if let frame = child.frame(id: id) {
//                return frame + positions[index]
//            }
//        }
        return nil
    }
}
