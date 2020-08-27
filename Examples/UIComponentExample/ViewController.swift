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
    componentView.animator = AnimatedReloadAnimator()
    componentView.component = ConstraintReader { constraint in
      HStack(spacing: 10) {
        HStack {
          Space(width: 50, height: 150).view().size(width: .fill).constraint(constraint).backgroundColor(.black)
          Space(width: 50, height: 150).view().backgroundColor(.green)
          Space(width: 50, height: 50).view().backgroundColor(.red)
        }.unboundedWidth().size(width: 120, height: 120)
        HStack {
          Space(width: 50, height: 150).view().backgroundColor(.green)
          Space(width: 50, height: 50).view().backgroundColor(.red)
        }
      }
    }
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		componentView.frame = view.bounds
	}
}
