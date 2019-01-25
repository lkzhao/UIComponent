//
//  FillViewProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-24.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public class FillViewProvider: FitViewProvider {
  public override func layout(size: CGSize) -> CGSize {
    _size = size
    if let width = width {
      _size.width = width
    }
    if let height = height {
      _size.height = height
    }
    return _size
  }
}
