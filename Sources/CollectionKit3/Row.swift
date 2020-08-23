//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

public struct Row: Component {
  public let spacing: CGFloat
  public let justifyContent: MainAxisAlignment
  public let alignItems: CrossAxisAlignment
  public let children: [Component]
  
  public func build() -> Element {
    RowElement(spacing: spacing,
               justifyContent: justifyContent,
               alignItems: alignItems,
               children: children.map { $0.build() })
  }
}

public extension Row {
  init(spacing: CGFloat = 0, justifyContent: MainAxisAlignment = .start, alignItems: CrossAxisAlignment = .start, @ComponentBuilder _ content: () -> ComponentBuilderItem) {
    self.init(spacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              children: content().components)
  }
}
