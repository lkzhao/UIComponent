//
//  IrregularLayoutViewController.swift
//  UIComponentExample
//
//  Created by y H on 2021/7/29.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIKit
import UIComponent

class IrregularLayoutViewController: ComponentViewController {
  
  let defaultData: [CoverModel] = (0...30).map { _ in CoverModel() }
  
  override var component: Component {
    VStack {
      for item in defaultData {
        AsyncImage(item.cover).id(item.id).size(width: 300, height: 300)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
}
