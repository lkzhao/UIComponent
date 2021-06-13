//
//  ViewController.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 2018-12-13.
//  Copyright © 2018 Luke Zhao. All rights reserved.
//

import UIComponent
import UIKit

class ViewController: UIViewController {
  let componentView = ComponentScrollView()
  
  var cards: [CardData] = [
    CardData(title: "Custom View Example", subtitle: "Checkout CustomViewExample.swift"),
    CardData(title: "Item 2", subtitle: "Item 2"),
    CardData(title: "Item 3", subtitle: "Item 3"),
    CardData(title: "Item 4", subtitle: "Item 4"),
    CardData(title: "Item 5", subtitle: "Item 5"),
    CardData(title: "Item 6", subtitle: "Item 6"),
    CardData(title: "Item 7", subtitle: "Item 7")
  ] {
    didSet {
      updateComponent()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    componentView.animator = AnimatedReloadAnimator()
    TappableViewConfiguration.default = TappableViewConfiguration { view, isHighlighted in
      let scale: CGFloat = isHighlighted ? 0.9 : 1.0
      UIView.animate(withDuration: 0.2) {
        view.transform = .identity.scaledBy(x: scale, y: scale)
      }
    }
    view.addSubview(componentView)
    componentView.contentInsetAdjustmentBehavior = .always
    updateComponent()
  }
  
  func updateComponent() {
    componentView.component = VStack {
      Join {
        for (index, card) in cards.enumerated() {
          Card(data: card).tappableView { [unowned self] in
            print("Tapped \(card.title)")
            self.cards.remove(at: index)
          }
        }
        HStack(spacing: 10, justifyContent: .center, alignItems: .center) {
          Image(systemName: "plus")
          Text("Add")
        }.inset(20).size(width: .fill).tappableView { [unowned self] in
          self.cards.append(CardData(title: "New Item \(self.cards.count)",
                                     subtitle: "New Item \(self.cards.count)"))
        }.id("new-button")
      } separator: {
        Separator(color: .separator)
      }
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    componentView.frame = view.bounds
  }
}

