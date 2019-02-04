//
//  OverlayProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2/3/19.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

open class OverlayProvider: Provider {
  open var back: Provider
  open var front: Provider
  public init(back: Provider, front: Provider) {
    self.back = back
    self.front = front
  }
  open func layout(size: CGSize) -> CGSize {
    let frontSize = front.layout(size: size)
    let _ = back.layout(size: frontSize)
    return frontSize
  }

  open func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    return back.views(in: frame) + front.views(in: frame)
  }
}
