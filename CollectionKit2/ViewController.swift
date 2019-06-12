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

  let reloadButton: UIButton = {
    let button = UIButton()
    button.setTitle("Reload", for: .normal)
    button.titleLabel?.font = .boldSystemFont(ofSize: 20)
    button.backgroundColor = UIColor(hue: 0.6, saturation: 0.68, brightness: 0.98, alpha: 1)
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: -12)
    button.layer.shadowRadius = 10
    button.layer.shadowOpacity = 0.1
    return button
  }()

  var currentDataIndex = 0
  var data: [[Int]] = [
    [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18],
    [2,3,5,8,10],
    [8,9,10,11,12,13,14,15,16],
    [],
    ]

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
    view.addSubview(reloadButton)
    collectionView.provider = InfiniteListProvider()
  }

  @objc func reload() {
    collectionView.setNeedsReload()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
    reloadButton.frame = CGRect(x: 0, y: view.bounds.height - 60,
                                width: view.bounds.width, height: 60)
  }
}
