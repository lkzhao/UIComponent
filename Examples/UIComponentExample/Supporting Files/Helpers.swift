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

extension UIColor {
  static let systemColors: [UIColor] = [.systemRed, .systemBlue, .systemPink, .systemTeal, .systemGray, .systemFill, .systemGreen, .systemGreen, .systemYellow, .systemPurple, .systemOrange]
  static func randomSystemColor() -> UIColor {
    systemColors.randomElement()!
  }
}

extension CGRect {
  var center: CGPoint {
    return CGPoint(x: midX, y: midY)
  }

  init(center: CGPoint, size: CGSize) {
    self.init(origin: CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2), size: size)
  }
}
