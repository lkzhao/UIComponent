//  Created by Luke Zhao on 2/12/26.

internal struct RenderUpdateContext {
    let resolvedAnimator: Animator
    let renderableID: String
}

internal enum RenderUpdateContextValues {
    private static let key = "currentRenderUpdateContext"

    internal static var current: RenderUpdateContext? {
        get {
            Thread.current.threadDictionary[key] as? RenderUpdateContext
        }
        set {
            Thread.current.threadDictionary[key] = newValue
        }
    }

    internal static func with<Result>(context: RenderUpdateContext, accessor: () throws -> Result) rethrows -> Result {
        let previous = current
        current = context
        defer { current = previous }
        return try accessor()
    }
}
