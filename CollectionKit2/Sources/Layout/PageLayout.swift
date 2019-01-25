//
//  PageLayout.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-23.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

public class PageLayout: SortedLayoutProvider {
  public override func simpleLayout(size: CGSize) -> [CGRect] {
    return children.enumerated().map {
      CGRect(origin: CGPoint(x: CGFloat($0) * size.width, y: 0),
             size: getSize(child: $1, maxSize: size))
    }
  }
}
