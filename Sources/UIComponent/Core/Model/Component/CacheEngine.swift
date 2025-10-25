//  Created by Luke Zhao on 4/24/25.


struct CacheEngine {
    private static var globalCachingData: [String: Any] = [:]
    private lazy var cachingData: [String: Any] = [:]
    private lazy var transientCachingData: [String: Any] = [:]
    private lazy var accessedKeys: Set<String> = []
    private var hasTransientData: Bool = false

    internal mutating func loadCachingData<T>(id: String, scope: CacheScope, generator: () -> T) -> T {
        switch scope {
        case .component:
            return loadTransientCachingData(id: id, generator: generator)
        case .hostingView:
            return loadHostingViewCachingData(id: id, generator: generator)
        case .global:
            return loadGlobalCachingData(id: id, generator: generator)
        }
    }

    internal mutating func endLoading() {
        guard hasTransientData, !transientCachingData.isEmpty else { return }
        let toBeDeleted = transientCachingData.keys.filter { !accessedKeys.contains($0) }
        for key in toBeDeleted {
            transientCachingData[key] = nil
        }
        accessedKeys.removeAll()
    }

    internal static func clearGlobalCache() {
        globalCachingData.removeAll()
    }

    internal static func clearGlobalCacheData(for key: String) {
        globalCachingData[key] = nil
    }

    private mutating func loadHostingViewCachingData<T>(id: String, generator: () -> T) -> T {
        let data = (cachingData[id] as? T) ?? generator()
        cachingData[id] = data
        return data
    }

    private mutating func loadTransientCachingData<T>(id: String, generator: () -> T) -> T {
        hasTransientData = true
        accessedKeys.insert(id)
        let data = (transientCachingData[id] as? T) ?? generator()
        transientCachingData[id] = data
        return data
    }

    private func loadGlobalCachingData<T>(id: String, generator: () -> T) -> T {
        let data = (Self.globalCachingData[id] as? T) ?? generator()
        Self.globalCachingData[id] = data
        return data
    }
}
