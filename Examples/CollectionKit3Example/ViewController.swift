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
    collectionView.component = Flow(lineSpacing: 10, interitemSpacing: 20, justifyContent: .center, alignItems: .center) {
      Space(width: 50, height: 50).view().backgroundColor(.black)
      Space(width: 50, height: 150).view().backgroundColor(.green)
      Space(width: 50, height: 50).view().backgroundColor(.red)
      Space(width: 50, height: 50).view().backgroundColor(.black)
      Space(width: 50, height: 50).view().backgroundColor(.green)
      Space(width: 50, height: 50).view().backgroundColor(.red)
      Space(width: 50, height: 50).view().backgroundColor(.black)
      Space(width: 50, height: 50).view().backgroundColor(.green)
      Space(width: 150, height: 50).view().backgroundColor(.red)
    }
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame = view.bounds
	}
}
