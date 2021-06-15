//
//  ComponentBuilderExample.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 8/23/20.
//  Copyright © 2020 Luke Zhao. All rights reserved.
//

import UIKit
import UIComponent

extension UIView {
  public var parentViewController: UIViewController? {
    var responder: UIResponder? = self
    while responder is UIView {
      responder = responder!.next
    }
    return responder as? UIViewController
  }
  
  public func present(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
    parentViewController?.present(viewController, animated: true, completion: completion)
  }
}
