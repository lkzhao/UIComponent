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
    let text2 = Text("World", font: UIFont.boldSystemFont(ofSize: 20)).with(\.textColor, .blue).with(\.backgroundColor, .green)
    collectionView.component = Column(spacing: 10, justifyContent: .spaceBetween) {
      Row(spacing: 20, justifyContent: .spaceBetween) {
        Text("Hello").id("test").with(\.textColor, .red)
        text2.flex(fit: .tight)
        Text("Again")
      }
      Row {
        Text("Why")
        Text("Not")
      }
      Row {
        Text("Another")
      }
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
      Text("Another")
    }
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame = view.bounds
	}
}
