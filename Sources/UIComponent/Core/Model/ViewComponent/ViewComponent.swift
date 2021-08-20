//  Created by Luke Zhao on 8/22/20.

import Foundation

@dynamicMemberLookup
public protocol ViewComponent: Component {
  associatedtype R: ViewRenderNode
  func layout(_ constraint: Constraint) -> R
}

extension ViewComponent {
  public func layout(_ constraint: Constraint) -> RenderNode {
    layout(constraint) as R
  }
}

public struct ViewModifierComponent<View, Content: ViewComponent, Result: ViewRenderNode>: ViewComponent where Content.R.View == View, Result.View == View {
  let content: Content
  let modifier: (Content.R) -> Result

  public func layout(_ constraint: Constraint) -> Result {
    modifier(content.layout(constraint))
  }
}

public typealias ViewUpdateComponent<Content: ViewComponent> = ViewModifierComponent<Content.R.View, Content, ViewUpdateRenderNode<Content.R.View, Content.R>>

public typealias ViewKeyPathUpdateComponent<Content: ViewComponent, Value> = ViewModifierComponent<Content.R.View, Content, ViewKeyPathUpdateRenderNode<Content.R.View, Value, Content.R>>

public typealias ViewIDComponent<Content: ViewComponent> = ViewModifierComponent<Content.R.View, Content, ViewIDRenderNode<Content.R.View, Content.R>>

public typealias ViewAnimatorComponent<Content: ViewComponent> = ViewModifierComponent<Content.R.View, Content, ViewAnimatorRenderNode<Content.R.View, Content.R>>

public typealias ViewReuseKeyComponent<Content: ViewComponent> = ViewModifierComponent<Content.R.View, Content, ViewReuseKeyRenderNode<Content.R.View, Content.R>>
