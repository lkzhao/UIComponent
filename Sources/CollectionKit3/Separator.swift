//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/24/20.
//

import UIKit

public struct Separator: ViewComponentBuilder {
  public let id: String
  public let color: UIColor
  public init(id: String = UUID().uuidString, color: UIColor = UIColor.systemGroupedBackground) {
    self.id = id
    self.color = color
  }
  public func build() -> some ViewComponent {
    SimpleViewComponent<UIView>(id: id).backgroundColor(color).size(width: .fill, height: 1)
  }
}
