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
    reload()
  }

  let labelAnimator = AnimatedReloadAnimator()
  @objc func reload() {
    let labels: [Provider] = (data[currentDataIndex]).map { data in
      ClosureViewProvider(key: "\(data)",
        animator: labelAnimator,
        update: { (view: UILabel) in
          view.text = "\(data)"
          view.backgroundColor = UIColor(hue: CGFloat(data) / 30,
                                         saturation: 0.68,
                                         brightness: 0.98,
                                         alpha: 1)
        },
        size: { _ in
          CGSize(width: 100, height: 100)
        })
    }
    currentDataIndex = (currentDataIndex + 1) % data.count
    let flex = FlexLayout(
      children: (0..<3).map { data in
        ClosureViewProvider(key: "test-\(data)",
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
          Flex(child: ClosureViewProvider(key: "test-flex",
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

          Flex(flex: 2, child: ClosureViewProvider(key: "test-flex2",
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
    let flow = FlowLayout(children:labels)
    let extra: [Provider] = (0..<15).map { data in
      ClosureViewProvider(key: "test-sticky-\(data)",
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
    }
//    collectionView.provider = VisibleFrameInset(
//      insets: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
//      child: StickyColumnLayout(children: [
//          Sticky(child: flex),
//          flow,
//          Sticky(child: ClosureViewProvider(key: "test-sticky2",
//                                            update: { (view: UILabel) in
//                                              view.text = "S1"
//                                              view.backgroundColor = UIColor(hue: CGFloat(30) / 30,
//                                                                             saturation: 0.68,
//                                                                             brightness: 0.98,
//                                                                             alpha: 1)
//                                            },
//                                            size: { _ in
//                                              CGSize(width: 100, height: 50)
//          })),
//          ] + extra)
//    )

    let titleLabel = UILabel()
    titleLabel.text = "Congratz!"
    let title2Label = UILabel()
    title2Label.text = "Congratz! Lol this"

    let cardView = UIView()
    cardView.backgroundColor = .red
    cardView.layer.cornerRadius = 17

    let card = OverlayProvider(
      back: FillViewProvider(view: cardView),
      front: InsetLayout(
        insets: UIEdgeInsets(top: 20, left: 20,
                             bottom: 20, right: 20),
        child: ColumnLayout(
          fitCrossAxis: true,
          alignItems: .center,
          children: [
            FitViewProvider(view: titleLabel),
            FitViewProvider(view: title2Label)
            ])
      )
    )
    collectionView.provider =
      InsetLayout(
        insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20),
        child: ColumnLayout(
          justifyContent: .center,
          alignItems: .start,
          children: [
            card
          ]))
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
    reloadButton.frame = CGRect(x: 0, y: view.bounds.height - 44,
                                width: view.bounds.width, height: 44)
  }

}

