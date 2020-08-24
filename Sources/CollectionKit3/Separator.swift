//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/24/20.
//

import UIKit

public struct Separator: ViewComponentBuilder {
  public let color: UIColor
  public init(color: UIColor = UIColor.systemGroupedBackground) {
    self.color = color
  }
  public func build() -> some ViewComponent {
    UIViewComponent().backgroundColor(color).size(width: .fill, height: 1)
  }
}
