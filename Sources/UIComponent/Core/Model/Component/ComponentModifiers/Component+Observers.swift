import UIKit

extension Component {
    /// Provides a reader for the render node of the component.
    /// - Parameter reader: A closure that receives the render node.
    /// - Returns: A `RenderNodeReader` component that allows reading the render node.
    public func renderNodeReader(_ reader: @escaping (Self.R) -> Void) -> RenderNodeReader<Self> {
        RenderNodeReader(content: self, reader)
    }

    /// Adds a callback to be invoked when the visible bounds of the component change.
    /// - Parameter callback: A closure that is called with the new size and visible rectangle.
    /// - Returns: A `VisibleBoundsObserverComponent` that invokes the callback when the visible bounds change.
    public func onVisibleBoundsChanged(_ callback: @escaping (CGSize, CGRect) -> Void) -> VisibleBoundsObserverComponent<Self> {
        VisibleBoundsObserverComponent(content: self, onVisibleBoundsChanged: callback)
    }
}
