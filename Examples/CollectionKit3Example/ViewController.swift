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
    collectionView.animator = AnimatedReloadAnimator()
    collectionView.component = ConstraintReader { constraint in
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
		collectionView.frame = view.bounds
	}
}
