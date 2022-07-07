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
