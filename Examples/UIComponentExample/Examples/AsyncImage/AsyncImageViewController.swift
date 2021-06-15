//
//  AsyncImageViewController.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 6/14/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIComponent
import UIKit

class AsyncImageViewController: ComponentViewController {
  override var component: Component {
    VStack {
      AsyncImage("https://unsplash.com/photos/Yn0l7uwBrpw/download?force=true&w=1920")!
        .size(width: .fill, height: .aspectPercentage(9 / 16))
    }
  }
}

