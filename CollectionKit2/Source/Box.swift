//
//  Box.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-05.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import CoreGraphics

public struct BoxConstraint {
  var minSize: CGSize
  var maxSize: CGSize
  var tightSize: CGSize?

  init(min: CGSize, max: CGSize, tight: CGSize? = nil) {
    self.minSize = min
    self.maxSize = max
    self.tightSize = tight
  }

  var transposed: BoxConstraint {
    return BoxConstraint(min: minSize.transposed, max: maxSize.transposed, tight: tightSize?.transposed)
  }
}
