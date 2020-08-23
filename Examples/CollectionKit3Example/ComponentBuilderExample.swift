//
//  ComponentBuilderExample.swift
//  CollectionKit3Example
//
//  Created by Luke Zhao on 8/23/20.
//  Copyright © 2020 Luke Zhao. All rights reserved.
//

import CollectionKit3

struct CardWrapper: ComponentBuilder {
  let data: CardData
  func build() -> Component {
    VStack {
      Text(data.title)
      Text(data.subtitle)
    }
  }
}
