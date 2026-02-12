//  Created by Luke Zhao on 2/12/26.

internal struct LayoutIdentityState {
    internal struct ExplicitScope {
        var id: String
        var nextChildIndex: Int = 0
    }

    var autoIndex: Int = 0
    var explicitScopes: [ExplicitScope] = []
}

internal enum LayoutIdentityContext {
    private static let currentStateKey = "currentLayoutIdentityState"
    private static let stateStackKey = "layoutIdentityStateStack"

    internal static var currentState: LayoutIdentityState {
        get {
            Thread.current.threadDictionary[currentStateKey] as? LayoutIdentityState ?? LayoutIdentityState()
        }
        set {
            Thread.current.threadDictionary[currentStateKey] = newValue
        }
    }

    private static var stateStack: [LayoutIdentityState] {
        get {
            Thread.current.threadDictionary[stateStackKey] as? [LayoutIdentityState] ?? []
        }
        set {
            Thread.current.threadDictionary[stateStackKey] = newValue
        }
    }

    internal static func beginLayoutPass<Result>(_ accessor: () throws -> Result) rethrows -> Result {
        saveCurrentState()
        currentState = LayoutIdentityState()
        defer { restoreCurrentState() }
        return try accessor()
    }

    internal static func withExplicitID<Result>(_ id: String?, accessor: () throws -> Result) rethrows -> Result {
        guard let id else {
            return try accessor()
        }

        var state = currentState
        state.explicitScopes.append(.init(id: id))
        currentState = state
        defer {
            var state = currentState
            _ = state.explicitScopes.popLast()
            currentState = state
        }
        return try accessor()
    }

    internal static func makeIdentity() -> String {
        var state = currentState
        if var scope = state.explicitScopes.popLast() {
            scope.nextChildIndex += 1
            state.explicitScopes.append(scope)
            currentState = state
            if scope.nextChildIndex == 1 {
                return "id:\(scope.id)"
            } else {
                return "id:\(scope.id)#\(scope.nextChildIndex)"
            }
        } else {
            state.autoIndex += 1
            currentState = state
            return "auto:\(state.autoIndex)"
        }
    }

    internal static func withState<Result>(state: LayoutIdentityState, accessor: () throws -> Result) rethrows -> Result {
        saveCurrentState()
        currentState = state
        defer { restoreCurrentState() }
        return try accessor()
    }

    private static func saveCurrentState() {
        stateStack.append(currentState)
    }

    private static func restoreCurrentState() {
        guard let state = stateStack.popLast() else {
            assertionFailure("Inbalanced layout identity save/restore")
            return
        }
        currentState = state
    }
}
