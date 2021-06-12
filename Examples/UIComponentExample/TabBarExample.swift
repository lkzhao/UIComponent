//
//  TabBarExample.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 6/8/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIComponent
import UIKit

public struct TabBarItem {
  public let image: UIImage
  public let handler: () -> Void
}

public struct TabBar: ComponentBuilder {
  public let items: [TabBarItem]
  public func build() -> Component {
    HStack(justifyContent: .spaceEvenly, alignItems: .center) {
      for item in items {
        Image(item.image).contentMode(.center).size(CGSize(width: 44, height: 44)).tappableView(item.handler)
      }
    }.size(height: 44)
  }
}
