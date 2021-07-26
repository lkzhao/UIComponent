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
  convenience init(width: CGFloat = 50, height: CGFloat = 50) {
    self.init("", width: width, height: height)
  }
  func build() -> Component {
    Space(width: width, height: height).styleColor(.systemBlue).overlay(Text(text).textColor(.white).textAlignment(.center).size(width: .fill, height: .fill))
  }
}


struct NumberBadge: ComponentBuilder {
  
  let text: String
  let isRoundStyle: Bool
  func build() -> Component {
    Text(text,
         font: .systemFont(ofSize: 14))
      .size(width: text.isEmpty ? 5 : 18, height: text.isEmpty ? 5 : 18)
      .adjustsFontSizeToFitWidth(true)
      .textColor(.white)
      .textAlignment(.center)
      .inset(2)
      .view()
      .backgroundColor(.systemRed)
      .update {
        $0.layer.cornerRadius = isRoundStyle ? min($0.frame.width, $0.frame.height) / 2 : 0
      }.clipsToBounds(true)
  }
  
  static func redPoint() -> Self {
    return NumberBadge("")
  }
  
  init(_ text: String, isRoundStyle: Bool = true) {
    self.text = text
    self.isRoundStyle = isRoundStyle
  }
  
  init(_ int: Int, isRoundStyle: Bool = true) {
    self.text = "\(int)"
    self.isRoundStyle = isRoundStyle
  }
  
}

struct BannerBadge: ComponentBuilder {
  let text: String
  func build() -> Component {
    Text(text, font: .systemFont(ofSize: 11)).textAlignment(.center).textColor(.white).backgroundColor(.systemRed).adjustsFontSizeToFitWidth(true).size(height: .absolute(15)).inset(h: 2)
  }
  
  init(_ text: String) {
    self.text = text
  }
  
}
