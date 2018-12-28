//
//  CountedSet.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2018-12-27.
//  Copyright © 2018 Luke Zhao. All rights reserved.
//

import Foundation

struct CountedSet<Element: Hashable> {
  var countByElement: [Element: Int] = [:]

  mutating func insert(_ element: Element) {
    countByElement[element, default: 0] += 1
  }

  mutating func remove(_ element: Element) {
    if let count = countByElement[element], count > 1 {
      countByElement[element] = count - 1
    } else {
      countByElement[element] = nil
    }
  }

  func contains(_ element: Element) -> Bool {
    return countByElement[element] != nil
  }
}
