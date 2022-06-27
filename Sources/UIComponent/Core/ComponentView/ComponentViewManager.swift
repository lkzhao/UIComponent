//  Created by Luke Zhao on 6/27/22.

import Foundation

public struct ComponentViewProxy {
    internal weak var view: ComponentDisplayableView?
    public func setNeedsReload() {
        view?.setNeedsReload()
    }
    public func reloadData() {
        view?.reloadData()
    }
}

internal class ComponentViewMananger {
    static let shared = ComponentViewMananger()
    
    private var stack: [ComponentViewProxy] = []
    
    var last: ComponentViewProxy? {
        stack.last
    }
    
    func push(view: ComponentDisplayableView) {
        stack.append(ComponentViewProxy(view: view))
    }

    func pop() {
        stack.removeLast()
    }
}
