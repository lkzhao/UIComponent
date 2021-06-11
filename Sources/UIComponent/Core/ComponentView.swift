//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/27/20.
//

import UIKit

open class ComponentView: UIView, ComponentDisplayableView {
  lazy public var engine: ComponentEngine = ComponentEngine(view: self)

  public convenience init(component: Component) {
    self.init()
    self.component = component
  }

  open override func safeAreaInsetsDidChange() {
    super.safeAreaInsetsDidChange()
    setNeedsInvalidateLayout()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    engine.layoutSubview()
  }
  
  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    engine.sizeThatFits(size)
  }
}