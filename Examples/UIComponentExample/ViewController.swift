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
		view.addSubview(componentView)
    componentView.contentInsetAdjustmentBehavior = .always
    updateComponent()
	}
  
  func updateComponent() {
    componentView.component = VStack {
      VStack(spacing: 10) {
        Text("This is an example")
        Text("This is an example", font: UIFont.systemFont(ofSize: 12))
        ForEach(cards) { card in
          Card(data: card)
            .backgroundColor(.gray)
            .tappableView {
              print("Tapped \(card.title)")
            }
        }
        HStack {
          Image(systemName: "plus")
          Text("Add")
        }.tappableView { [unowned self] in
          self.cards.append(CardData(title: "New Item \(self.cards.count)",
                                     subtitle: "New Item \(self.cards.count)"))
        }
        Space(height: 100)
      }.scrollView().flex()
      TabBar(items: [
        TabBarItem(image: UIImage(systemName: "circle")!, handler: {
          print("Tap tab 1")
        }),
        TabBarItem(image: UIImage(systemName: "triangle")!, handler: {
          print("Tap tab 2")
        }),
        TabBarItem(image: UIImage(systemName: "square")!, handler: {
          print("Tap tab 3")
        })
      ])
    }
  }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		componentView.frame = view.bounds
	}
}
