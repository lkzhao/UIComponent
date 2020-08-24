//
//  ComponentBuilderExample.swift
//  CollectionKit3Example
//
//  Created by Luke Zhao on 8/23/20.
//  Copyright © 2020 Luke Zhao. All rights reserved.
//

import UIKit
import CollectionKit3

struct CardBuilder: ComponentBuilder {
  let data: CardData
  func build() -> Component {
    VStack {
      Text(data.title)
      Text(data.subtitle)
    }
  }
}
