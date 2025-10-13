import UIKit

/// Direction describing the scrolling axis monitored by scroll observers.
public enum ScrollDirection {
    case horizontal
    case vertical
}

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

    /// Invokes the block when the component scrolls close to the end in the vertical direction.
    /// - Parameters:
    ///   - pages: The number of view heights away from the end that should trigger the block.
    ///   - block: Closure executed when the threshold is reached.
    /// - Returns: A component observing vertical scroll position.
    /// - Note: The closure may be invoked multiple times while the scroll position remains within the trigger range.
    public func onVerticalScrollToEnd(pages: CGFloat = 2.0, _ block: @escaping () -> Void) -> some Component {
        onScrollToEnd(direction: .vertical, pages: pages, block)
    }

    /// Invokes the block when the component scrolls close to the end in the horizontal direction.
    /// - Parameters:
    ///   - pages: The number of view widths away from the end that should trigger the block.
    ///   - block: Closure executed when the threshold is reached.
    /// - Returns: A component observing horizontal scroll position.
    /// - Note: The closure may be invoked multiple times while the scroll position remains within the trigger range.
    public func onHorizontalScrollToEnd(pages: CGFloat = 2.0, _ block: @escaping () -> Void) -> some Component {
        onScrollToEnd(direction: .horizontal, pages: pages, block)
    }

    /// Invokes the block when the component scrolls close to the end in the specified direction.
    /// - Parameters:
    ///   - direction: The direction to observe for scrolling to the end.
    ///   - pages: The number of view lengths away from the end that should trigger the block.
    ///   - block: Closure executed when the threshold is reached.
    /// - Returns: A component observing scroll position in the requested direction.
    /// - Note: The closure may be invoked multiple times while the scroll position remains within the trigger range.
    public func onScrollToEnd(
        direction: ScrollDirection = .vertical,
        pages: CGFloat = 2.0,
        _ block: @escaping () -> Void
    ) -> some Component {
        onVisibleBoundsChanged { size, visibleBounds in
            switch direction {
            case .vertical:
                if visibleBounds.maxY >= size.height - visibleBounds.height * pages {
                    block()
                }
            case .horizontal:
                if visibleBounds.maxX >= size.width - visibleBounds.width * pages {
                    block()
                }
            }
        }
    }
}
