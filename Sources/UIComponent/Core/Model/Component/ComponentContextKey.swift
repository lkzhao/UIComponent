//  Created by Luke Zhao on 4/24/25.


/// A key for storing and retrieving values in the component context.
///
/// Use `.withContext(_ key:value:)` to set the context value for a specific key to a component.
/// Use `.contextValue(for:)` to retrieve the context value for a specific key from a component.
public struct ComponentContextKey<Value>: Hashable, Equatable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
