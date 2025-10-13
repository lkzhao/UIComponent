import UIKit

extension Component {
    /// Makes the component lazy with a fixed size, deferring its internal layout and rendering until needed.
    /// - Parameter size: The fixed size to use for the lazy component.
    /// - Returns: A `LazyComponent` that wraps the current component with the specified fixed size.
    public func lazy(size: CGSize) -> LazyComponent<Self> {
        LazyComponent(component: self, size: size)
    }

    /// Makes the component lazy with specified dimensions, deferring its internal layout and rendering until needed.
    /// - Parameters:
    ///   - width: The width to use for the lazy component.
    ///   - height: The height to use for the lazy component.
    /// - Returns: A `LazyComponent` that wraps the current component with the specified dimensions.
    public func lazy(width: CGFloat, height: CGFloat) -> LazyComponent<Self> {
        lazy(size: CGSize(width: width, height: height))
    }

    /// Makes the component lazy with a custom size provider, deferring its internal layout and rendering until needed.
    /// - Parameter sizeProvider: A closure that determines the size based on the given constraint.
    /// - Returns: A `LazyComponent` that wraps the current component using the provided size calculation.
    public func lazy(sizeProvider: @escaping (Constraint) -> CGSize) -> LazyComponent<Self> {
        LazyComponent(component: self, sizeProvider: sizeProvider)
    }
}
