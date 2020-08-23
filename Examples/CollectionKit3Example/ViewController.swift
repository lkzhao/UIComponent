//
//  ViewController.swift
//  CollectionKit3
//
//  Created by Luke Zhao on 2018-12-13.
//  Copyright © 2018 Luke Zhao. All rights reserved.
//

import CollectionKit3
import UIKit

class ViewController: UIViewController {
	let collectionView = CollectionView()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(collectionView)
    
    collectionView.contentInsetAdjustmentBehavior = .always
    let text2 = Text("World", font: UIFont.boldSystemFont(ofSize: 20)).with(\.textColor, .blue).size(width: 50, height: 100).with(\.backgroundColor, .green)
    collectionView.component = Column {
      Row(spacing: 20, justifyContent: .spaceBetween, alignItems: .center) {
        Text("Hello").id("test").with(\.textColor, .red)
        text2.inset(by: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)).view().with(\.backgroundColor, .red).with(\.clipsToBounds, true).size(width: 100, height: 100)
        Text("Again")
      }.inset(by: UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20))
      Space(width: 200, height: 44).view().with(\.backgroundColor, .green).flex()
      Row(spacing: 20, justifyContent: .spaceBetween, alignItems: .center) {
        Text("Hey")
        Text("What")
        Text("Up")
      }.scrollView().with(\.backgroundColor, .blue).size(width: 100, height: 50)
      CardWrapper(data: CardData(title: "Test", subtitle: "out this card"))
    }
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame = view.bounds
	}
}
