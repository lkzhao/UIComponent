//
//  AsyncImageViewController.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 6/14/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIComponent
import UIKit
import Hero

struct ImageData {
  let url: URL
  let size: CGSize
}

class AsyncImageViewController: ComponentViewController {
  let images = [
    ImageData(url: URL(string: "https://unsplash.com/photos/Yn0l7uwBrpw/download?force=true&w=640")!,
          size: CGSize(width: 640, height: 360)),
    ImageData(url: URL(string: "https://unsplash.com/photos/J4-xolC4CCU/download?force=true&w=640")!,
          size: CGSize(width: 640, height: 800)),
    ImageData(url: URL(string: "https://unsplash.com/photos/biggKnv1Oag/download?force=true&w=640")!,
          size: CGSize(width: 640, height: 434)),
    ImageData(url: URL(string: "https://unsplash.com/photos/MR2A97jFDAs/download?force=true&w=640")!,
          size: CGSize(width: 640, height: 959)),
    ImageData(url: URL(string: "https://unsplash.com/photos/oaCnDk89aho/download?force=true&w=640")!,
          size: CGSize(width: 640, height: 426)),
    ImageData(url: URL(string: "https://unsplash.com/photos/MOfETox0bkE/download?force=true&w=640")!,
          size: CGSize(width: 640, height: 426)),
  ]

  override var component: Component {
    Waterfall(columns: 2, spacing: 1) {
      for image in images {
        AsyncImage(image.url)
          .size(width: .fill, height: .aspectPercentage(image.size.height / image.size.width))
          .with(\.hero.id, image.url.absoluteString)
          .with(\.hero.modifiers, [.forceNonFade])
          .tappableView {
            let detailVC = AsyncImageDetailViewController()
            detailVC.image = image
            $0.parentViewController?.navigationController?.isHeroEnabled = true
            $0.parentViewController?.navigationController?.pushViewController(detailVC, animated: true)
          }
      }
    }
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
    isHeroEnabled = true
    title = "Async Image"
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


class AsyncImageDetailViewController: ComponentViewController {
  var image: ImageData!

  override var component: Component {
    VStack {
      AsyncImage(image.url)
        .size(width: .fill, height: .aspectPercentage(image.size.height / image.size.width))
        .heroID(image.url.absoluteString)
        .tappableView {
          $0.parentViewController?.navigationController?.popViewController(animated: true)
        }
    }
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
    isHeroEnabled = true
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.heroModifiers = [.fade]
  }
}

