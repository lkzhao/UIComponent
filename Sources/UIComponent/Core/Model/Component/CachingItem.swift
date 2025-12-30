//  Created by Luke Zhao on 11/8/24.

/// The scope that determines the lifetime of the cached item.
public enum CacheScope {
    /// The item will be cached until this component is no longer in the hosting view's component tree.
    case component

    /// The item will be cached until the hosting view is released.
    case hostingView

    /// The item will be cached until the application is terminated. Or by manually
    /// calling `CachingItem.clearGlobalCacheData(for:)` or `CachingItem.clearGlobalCache()`.
    case global
}

/// A Component that caches data item.
///
/// It is useful when you want to cache item that is expensive to generate
/// or if you want to share the same item across multiple reload.
///
/// The item will be released when the hosting view is released
///
/// `itemGenerator` will be called to generate the item if it's not in the view's cache.
/// `componentBuilder` will be called to build the component with the item.
public struct CachingItem<T, C: Component>: Component {
    /// The key to identify the item in the cache.
    public let key: String

    /// The scope of the cache. Default is `.component`.
    public let scope: CacheScope

    /// The closure that generates the item. Will only be called if the item is not in the cache.
    public let itemGenerator: () -> T

    /// The closure that builds the component with the item
    public let componentBuilder: (T) -> C

    @Environment(\.hostingView) private var hostingView

    /// Initializes a new `CachingItem` with the provided key, item generator, and component builder.
    /// - Parameters:
    ///  - key: The key to identify the item in the cache.
    ///  - scope: The scope of the cache. Default is `.component`.
    ///  - itemGenerator: The closure that generates the item. Will only be called if the item is not in the cache.
    ///  - componentBuilder: The closure that builds the component
    public init(key: String, scope: CacheScope = .component, itemGenerator: @escaping () -> T, componentBuilder: @escaping (T) -> C) {
        self.key = key
        self.scope = scope
        self.itemGenerator = itemGenerator
        self.componentBuilder = componentBuilder
    }

    /// Component protocol method
    public func layout(_ constraint: Constraint) -> C.R {
        let data: T = hostingView?.componentEngine.loadCachingData(id: key, scope: scope, generator: itemGenerator) ?? itemGenerator()
        return componentBuilder(data).layout(constraint)
    }

    // MARK: - Static methods

    /// Clears the global cache for all items.
    public static func clearGlobalCache() {
        CacheEngine.clearGlobalCache()
    }

    /// Clears the global cache data for the specified key.
    /// - Parameter key: The key of the item to clear from the global cache.
    public static func clearGlobalCacheData(forKey key: String) {
        CacheEngine.clearGlobalCacheData(for: key)
    }
}
