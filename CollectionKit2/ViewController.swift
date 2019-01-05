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
    collectionView.animator = AnimatedReloadAnimator()
    view.addSubview(collectionView)
    reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
    view.addSubview(reloadButton)
    reload()
  }

  @objc func reload() {
    currentDataIndex = (currentDataIndex + 1) % data.count
    let labels: [Provider] = (data[currentDataIndex]).map { data in
      BaseViewProvider(key: "\(data)",
        update: { (view: UILabel) in
          view.text = "\(data)"
          view.backgroundColor = UIColor(hue: CGFloat(data) / 30,
                                         saturation: 0.68,
                                         brightness: 0.98,
                                         alpha: 1)
        },
        size: {
          CGSize(width: 100 + (data == 0 ? 30 : 0), height: $0.height)
        })
    }
    collectionView.provider = InsetLayoutProvider(
      insets: UIEdgeInsets(top: 50, left: 0, bottom: 50, right: 0),
      child: FlexLayout(
        children: (0..<3).map { data in
          BaseViewProvider(key: "test-\(data)",
            update: { (view: UILabel) in
              view.text = "\(data)"
              view.backgroundColor = UIColor(hue: CGFloat(data) / 30,
                                             saturation: 0.68,
                                             brightness: 0.98,
                                             alpha: 1)
            },
            size: { _ in
              CGSize(width: 30, height: 50)
          })
        } + [
            Flex(child: BaseViewProvider(key: "test-flex",
              update: { (view: UILabel) in
                view.text = "F"
                view.backgroundColor = UIColor(hue: CGFloat(10) / 30,
                                               saturation: 0.68,
                                               brightness: 0.98,
                                               alpha: 1)
              },
              size: {
                CGSize(width: $0.width, height: 50)
              })
            ),

            Flex(flex: 2, child: BaseViewProvider(key: "test-flex2",
                                         update: { (view: UILabel) in
                                          view.text = "F2"
                                          view.backgroundColor = UIColor(hue: CGFloat(15) / 30,
                                                                         saturation: 0.68,
                                                                         brightness: 0.98,
                                                                         alpha: 1)
                                         },
                                         size: {
                                          CGSize(width: $0.width, height: 50)
            }))
          ]
      )
    )
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
    reloadButton.frame = CGRect(x: 0, y: view.bounds.height - 44,
                                width: view.bounds.width, height: 44)
  }

}

