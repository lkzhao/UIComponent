//
//  CardData.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 6/15/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import Foundation

struct CardData {
  let id: String = "card-\(UUID().uuidString)"
  let title: String
  let subtitle: String
  
  static let testCards: [CardData] = (1..<7).map {
    CardData(title: "Item \($0)", subtitle: "Description \($0)")
  }
}
