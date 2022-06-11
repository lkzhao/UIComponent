//  Created by Luke Zhao on 8/22/20.

import BaseToolbox
import CoreGraphics
import Foundation
import UIKit

public protocol RenderNode {
    /// size of the render node
    var size: CGSize { get }

    /// positions of child render nodes
    var positions: [CGPoint] { get }

    /// child render nodes
    var children: [RenderNode] { get }

    /// Get indexes of the children that are visible in the given frame
    /// - Parameter frame: Parent component's visible frame in current component's coordinates.
    ///
    /// Discussion: This method is used in the default implementation of `visibleRenderables(in:)`
    /// It won't be called if `visibleRenderables(in:)` is overwritten.
    /// The default implementation for this methods is not optmized and will return all indexes regardless of the frame.
    func visibleIndexes(in frame: CGRect) -> IndexSet

    /// Get renderables that are visible in the given frame
    /// - Parameter frame: Parent component's visible frame in current component's coordinates.
    ///
    /// The default implementation recursively retrives all Renderable from visible children and combines them
    func visibleRenderables(in frame: CGRect) -> [Renderable]
}

// MARK: - Default implementation

extension RenderNode {
    public var children: [RenderNode] { [] }
    public var positions: [CGPoint] { [] }

    public func visibleIndexes(in frame: CGRect) -> IndexSet {
        IndexSet(0..<children.count)
    }

    public func visibleRenderables(in frame: CGRect) -> [Renderable] {
        var result = [Renderable]()
        let indexes = visibleIndexes(in: frame)
        for i in indexes {
            let child = children[i]
            let position = positions[i]
            let childFrame = CGRect(origin: position, size: child.size)
            let childVisibleFrame = frame.intersection(childFrame) - position
            let childRenderables = child.visibleRenderables(in: childVisibleFrame)
                .map {
                    Renderable(
                        id: $0.id,
                        keyPath: "\(type(of: self))-\(i)." + $0.keyPath,
                        animator: $0.animator,
                        renderNode: $0.renderNode,
                        frame: CGRect(origin: $0.frame.origin + position, size: $0.frame.size)
                    )
                }
            result.append(contentsOf: childRenderables)
        }
        return result
    }
}

extension RenderNode {
    public func frame(at index: Int) -> CGRect? {
        guard let size = children.get(index)?.size, let position = positions.get(index) else { return nil }
        return CGRect(origin: position, size: size)
    }

    public func frame(id: String) -> CGRect? {
        if let viewRenderNode = self as? (any ViewRenderNode), viewRenderNode.id == id {
            return CGRect(origin: .zero, size: size)
        }
        for (index, child) in children.enumerated() {
            if let frame = child.frame(id: id) {
                return frame + positions[index]
            }
        }
        return nil
    }
}
