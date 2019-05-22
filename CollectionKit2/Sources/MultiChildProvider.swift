//
//  MultiChildProvider.swift
//  CollectionKit2
//
//  Created by Honghao Zhang on 5/21/19.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

open class MultiChildProvider: Provider {
  open var children: [Provider] = []
  public init(children: [Provider]) {
    self.children = children
  }
  open func layout(size: CGSize) -> CGSize {
    return .zero
  }
  open func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
    return []
  }
}
