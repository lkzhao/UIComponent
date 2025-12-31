//  Created by Luke Zhao on 8/23/20.

/// A `ViewComponent`is a Component that encapsulates a platform view or a generator closure that can create a platform view.
/// See <doc:CustomView> for more details
public struct ViewComponent<View: PlatformView>: Component {
    /// The view instance that the component manages.
    public let view: View?
    /// A generator closure that can create a view instance when needed.
    public let generator: (() -> View)?
    
    /// Private initializer for the component that takes an optional `PlatformView` and an optional generator closure.
    /// - Parameters:
    ///   - view: An optional `PlatformView` instance to be managed by the component.
    ///   - generator: An optional closure that generates a `PlatformView` instance.
    private init(view: View?, generator: (() -> View)?) {
        self.view = view
        self.generator = generator
    }
    
    /// Public initializer that takes an optional view.
    /// If the view is not provided, the component will be initialized without a view and generator.
    /// - Parameter view: An optional view instance to be managed by the component.
    public init(view: View? = nil) {
        self.init(view: view, generator: nil)
    }
    
    /// Public initializer that takes a generator closure and wraps it with an `@autoclosure` to delay its execution.
    /// The generator is marked as `@escaping` because it will be stored and used later.
    /// - Parameter generator: A closure that generates a view instance, wrapped in an `@autoclosure`.
    public init(generator: @autoclosure @escaping () -> View) {
        self.init(view: nil, generator: generator)
    }

    /// Public initializer that takes a generator closure and wraps it with an `@autoclosure` to delay its execution.
    /// The generator is marked as `@escaping` because it will be stored and used later.
    /// - Parameter generator: A closure that generates a view instance.
    public init(generator: @escaping () -> View) {
        self.init(view: nil, generator: generator)
    }

    /// Creates a `ViewRenderNode` using the component's view or generator.
    /// It uses the `sizeThatFits` method of the view to determine the appropriate size within the given constraints.
    /// - Parameter constraint: A `Constraint` instance that provides the maximum size that the view can take.
    /// - Returns: A `ViewRenderNode` instance that represents the layout of the view.
    public func layout(_ constraint: Constraint) -> ViewRenderNode<View> {
        func computeSizeOnCurrentThread() -> CGSize {
#if os(macOS)
            let fitting = self.view?.fittingSize ?? .zero
            let clamped = CGSize(width: min(fitting.width, constraint.maxSize.width), height: min(fitting.height, constraint.maxSize.height))
            return clamped.bound(to: constraint)
#else
            return (self.view?.sizeThatFits(constraint.maxSize) ?? .zero).bound(to: constraint)
#endif
        }

        let resolvedSize: CGSize
        if Thread.isMainThread {
            resolvedSize = computeSizeOnCurrentThread()
        } else {
            resolvedSize = DispatchQueue.main.sync {
                computeSizeOnCurrentThread()
            }
        }
        return ViewRenderNode(size: resolvedSize, view: self.view, generator: generator)
    }
}

/// A `ViewRenderNode` encapsulates the layout information for a platform view and its associated generator.
public struct ViewRenderNode<View: PlatformView>: RenderNode {
    /// The calculated size of the view.
    public let size: CGSize
    /// The view instance managed by the render node.
    public let view: View?
    /// A generator closure that can create a view instance when needed.
    public let generator: (() -> View)?

    /// Initializes a `ViewRenderNode` with a specified size, optional view, and optional generator.
    /// - Parameters:
    ///   - size: The size of the view.
    ///   - view: An optional `PlatformView` instance.
    ///   - generator: An optional closure that generates a `PlatformView`.
    fileprivate init(size: CGSize, view: View?, generator: (() -> View)?) {
        self.size = size
        self.view = view
        self.generator = generator
    }

    /// Initializes a `ViewRenderNode` with a specified size and no view or generator.
    /// - Parameter size: The size of the view.
    public init(size: CGSize) {
        self.init(size: size, view: nil, generator: nil)
    }

    /// Initializes a `ViewRenderNode` with a specified size and a view.
    /// - Parameters:
    ///   - size: The size of the view.
    ///   - view: A `PlatformView` instance.
    public init(size: CGSize, view: View) {
        self.init(size: size, view: view, generator: nil)
    }

    /// Initializes a `ViewRenderNode` with a specified size and a generator.
    /// - Parameters:
    ///   - size: The size of the view.
    ///   - generator: A closure that generates a `PlatformView`.
    public init(size: CGSize, generator: @escaping (() -> View)) {
        self.init(size: size, view: nil, generator: generator)
    }

    /// Creates and returns a view instance, either from the existing view or by using the generator.
    /// - Returns: A view instance.
    public func makeView() -> View {
        if let view {
            return view
        } else if let generator {
            return generator()
        } else {
            return View()
        }
    }

    /// Updates the provided view with new data or state.
    /// - Parameter view: The `PlatformView` instance to update.
    public func updateView(_ view: View) {}

    public func contextValue(_ key: RenderNodeContextKey) -> Any? {
        guard let view else { return nil }
        if key == .id {
            return "view-at-\(ObjectIdentifier(view))"
        }
        return nil
    }
}

/// Extension to make `PlatformView` conform to `Component`, allowing it to be used within the component hierarchy.
extension PlatformView: Component {
    /// Lays out the view within the given constraints and returns a `ViewRenderNode` representing its layout.
    /// - Parameter constraint: The constraints within which the view should be laid out.
    /// - Returns: A `ViewRenderNode` representing the laid out view.
    public func layout(_ constraint: Constraint) -> ViewRenderNode<PlatformView> {
        func computeSizeOnCurrentThread() -> CGSize {
#if os(macOS)
            let fitting = fittingSize
            let clamped = CGSize(width: min(fitting.width, constraint.maxSize.width), height: min(fitting.height, constraint.maxSize.height))
            return constraint.isTight ? constraint.maxSize : clamped.bound(to: constraint)
#else
            return constraint.isTight ? constraint.maxSize : sizeThatFits(constraint.maxSize).bound(to: constraint)
#endif
        }

        let resolvedSize: CGSize
        if Thread.isMainThread {
            resolvedSize = computeSizeOnCurrentThread()
        } else {
            resolvedSize = DispatchQueue.main.sync {
                computeSizeOnCurrentThread()
            }
        }

        return ViewRenderNode(size: resolvedSize, view: self)
    }
}
