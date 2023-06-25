//  Created by Luke Zhao on 6/27/22.

import Foundation

internal class ComponentViewMananger {
    static let shared = ComponentViewMananger()
    
    private var stack: [ComponentDisplayableView] = []
    
    var last: ComponentDisplayableView? {
        stack.last
    }
    
    func push(view: ComponentDisplayableView) {
        stack.append(view)
    }

    func pop() {
        stack.removeLast()
    }
}

public func currentComponentView() -> ComponentDisplayableView? {
    ComponentViewMananger.shared.last
}

extension Component {
    /// A block that can be captured inside `layout` or `build` method to trigger a reload on the linked componentView
    public var reload: () -> Void {
        guard let componentView = currentComponentView() else {
            assertionFailure("reloadComponent should only be captured within `layout` or `build` method")
            return {}
        }
        return { [weak componentView] in
            componentView?.reloadData()
        }
    }
}
