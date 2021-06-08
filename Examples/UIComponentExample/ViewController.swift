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

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(componentView)
    
    componentView.contentInsetAdjustmentBehavior = .always
    componentView.component = VStack {
      Text("This is an example")
      Text("This is an example", font: UIFont.systemFont(ofSize: 12))
      HStack {
        Image(systemName: "plus")
        Text("Add")
      }
      Space(height: 50)
      Card(data: CardData(title: "Custom View Example",
                          subtitle: "Checkout CustomViewExample.swift")).backgroundColor(.gray).tappableView() {
                            print("Hello")
                          }
    }
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		componentView.frame = view.bounds
	}
}
