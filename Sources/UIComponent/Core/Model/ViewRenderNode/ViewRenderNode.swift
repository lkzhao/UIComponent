//  Created by Luke Zhao on 8/22/20.

import UIKit

public protocol UIComponentRenderableView {
  init()
}
extension UIView: UIComponentRenderableView {}

public enum ReuseStrategy {
    case automatic, noReuse, key(String)
}

@dynamicMemberLookup
public protocol ViewRenderNode: AnyViewRenderNode {
  associatedtype View: UIComponentRenderableView
  var reuseStrategy: ReuseStrategy { get }
  func makeView() -> View
  func updateView(_ view: View)
}

extension ViewRenderNode {
  public var reuseStrategy: ReuseStrategy { .automatic }
  public func makeView() -> View {
    View()
  }
  public func _makeView() -> Any {
    if View.self is UIView.Type {
      switch reuseStrategy {
      case .automatic:
        return ReuseManager.shared.dequeue(identifier: "\(type(of: self))", makeView() as! UIView)
      case .noReuse:
        return makeView()
      case .key(let key):
        return ReuseManager.shared.dequeue(identifier: key, makeView() as! UIView)
      }
    }
    return makeView()
  }
  public func _updateView(_ view: Any) {
    guard let view = view as? View else { return }
    return updateView(view)
  }
}
