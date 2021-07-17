//
//  CardViewController3.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 2018-12-13.
//  Copyright © 2018 Luke Zhao. All rights reserved.
//

import UIComponent
import UIKit

private struct Card: ComponentBuilder {
  let card: CardData
  let onTap: () -> Void
  func build() -> Component {
    VStack(spacing: 8) {
      Text(card.title, font: UIFont.boldSystemFont(ofSize: 22))
      Text(card.subtitle)
    }.inset(h: 20, v: 16).size(width: .fill).tappableView(onTap).id(card.id)
    .backgroundColor(.systemBackground)
    .with(\.layer.shadowColor, UIColor.black.cgColor)
    .with(\.layer.shadowRadius, 4)
    .with(\.layer.shadowOffset, CGSize(width: 0, height: 2))
    .with(\.layer.shadowOpacity, 0.2)
    .with(\.layer.cornerRadius, 8)
  }
}

class CardViewController3: ComponentViewController {
  var newCardIndex = CardData.testCards.count + 1
  private var cards: [CardData] = CardData.testCards {
    didSet {
      reloadComponent()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    componentView.animator = AnimatedReloadAnimator()
  }
  
  override var component: Component {
    VStack(spacing: 8) {
      HStack(spacing: 10, alignItems: .center, wrapper: .wrap) {
        Text("long long long long long long long long long long long long text").size(width: .percentage(0.8))
        Image(systemName: "plus")
        Text("this new text").backgroundColor(.systemBlue).textColor(.white)
        Text("this new text").backgroundColor(.systemPink).textColor(.white)
        Text("thisasdasdasfafsdf").backgroundColor(.systemTeal).textColor(.white)
      }.scrollView().backgroundColor(.systemRed)
      
//      for (index, card) in cards.enumerated() {
//        Card(card: card) { [unowned self] in
//          print("Tapped \(card.title)")
//          self.cards.remove(at: index)
//        }
//      }
//      AddCardButton { [unowned self] in
//        self.cards.append(CardData(title: "Item \(self.newCardIndex)",
//                                   subtitle: "Description \(self.newCardIndex)"))
//        self.newCardIndex += 1
//      }
    }.inset(20)
  }
}

