//
//  ViewController.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2018-12-13.
//  Copyright © 2018 Luke Zhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  let collectionView = CollectionView()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)

    collectionView.provider = TransposeLayoutProvider(
      child: WaterfallLayoutProvider(
        children: (0..<100).map { LabelViewProvider(text: "\($0)") }
      )
    )
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
  }

}

