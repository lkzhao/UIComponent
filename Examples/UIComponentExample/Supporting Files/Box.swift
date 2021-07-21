//
//  Box.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIKit
import UIComponent

class Box: ComponentBuilder {
  let width: CGFloat
  let height: CGFloat
  let text: String
  init(_ text: String, width: CGFloat = 50, height: CGFloat = 50) {
    self.width = width
    self.height = height
    self.text = text
  }
  convenience init(_ index: Int, width: CGFloat = 50, height: CGFloat = 50) {
    self.init("\(index)", width: width, height: height)
  }
  func build() -> Component {
    Space(width: width, height: height).styleColor(.systemBlue).overlay(Text(text).textColor(.white).textAlignment(.center).size(width: .fill, height: .fill))
  }
}
