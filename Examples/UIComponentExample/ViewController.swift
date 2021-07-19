//
//  ViewController.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 2018-12-13.
//  Copyright © 2018 Luke Zhao. All rights reserved.
//

import UIComponent
import UIKit

class ViewController: ComponentViewController {
  override var component: Component {
    VStack {
      Join {
        ExampleItem(name: "Card Example", viewController: CardViewController())
        ExampleItem(name: "Card Example 2", viewController: CardViewController2())
        ExampleItem(name: "Card Example 3", viewController: CardViewController3())
        ExampleItem(name: "AsyncImage Example", viewController: UINavigationController(rootViewController: AsyncImageViewController()))
        ExampleItem(name: "Tab Bar Example", viewController: TabBarViewController())
        ExampleItem(name: "Flex Layout Example", viewController: FlexLayoutViewController())
      } separator: {
        Separator()
      }
    }
  }
}

struct ExampleItem: ComponentBuilder {
  let name: String
  let viewController: () -> UIViewController
  init(name: String, viewController: @autoclosure @escaping () -> UIViewController) {
    self.name = name
    self.viewController = viewController
  }
  func build() -> Component {
    VStack {
      Text(name)
    }.inset(20).tappableView {
      $0.present(viewController())
    }
  }
}
