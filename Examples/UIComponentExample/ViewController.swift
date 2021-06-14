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
  
  var newCardIndex = 7
  var cards: [CardData] = (1..<7).map({
    CardData(title: "Item \($0)", subtitle: "Description \($0)")
  }) {
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
      AsyncImage("https://unsplash.com/photos/Yn0l7uwBrpw/download?force=true&w=1920")!.size(width: .fill, height: .aspectPercentage(9 / 16))
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
        self.cards.append(CardData(title: "Item \(self.newCardIndex)",
                                   subtitle: "Description \(self.newCardIndex)"))
        self.newCardIndex += 1
      }.id("new-button")
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    componentView.frame = view.bounds
  }
}

