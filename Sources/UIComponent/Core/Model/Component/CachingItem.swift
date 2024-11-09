//
//  CachingItem.swift
//  UIComponent
//
//  Created by Luke Zhao on 11/8/24.
//

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

    /// The closure that generates the item. Will only be called if the item is not in the cache.
    public let itemGenerator: () -> T

    /// The closure that builds the component with the item
    public let componentBuilder: (T) -> C

    @Environment(\.hostingView) private var hostingView

    /// Initializes a new `CachingItem` with the provided key, item generator, and component builder.
    /// - Parameters:
    ///  - key: The key to identify the item in the cache.
    ///  - itemGenerator: The closure that generates the item. Will only be called if the item is not in the cache.
    ///  - componentBuilder: The closure that builds the component
    public init(key: String, itemGenerator: @escaping () -> T, componentBuilder: @escaping (T) -> C) {
        self.key = key
        self.itemGenerator = itemGenerator
        self.componentBuilder = componentBuilder
    }

    /// Component protocol method
    public func layout(_ constraint: Constraint) -> C.R {
        let data: T = hostingView?.componentEngine.loadCachingData(id: key, generator: itemGenerator) ?? itemGenerator()
        return componentBuilder(data).layout(constraint)
    }
}
