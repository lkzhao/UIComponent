//
//  AsyncImageExample.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 6/14/21.
//  Copyright © 2021 Luke Zhao. All rights reserved.
//

import UIComponent
import UIKit
import Kingfisher

struct AsyncImage: ViewComponentBuilder {
  public let url: URL
  
  public init(_ url: URL) {
    self.url = url
  }
  
  public init?(_ urlString: String) {
    guard let url = URL(string: urlString) else { return nil }
    self.url = url
  }
  
  func build() -> ViewUpdateComponent<SimpleViewComponent<UIImageView>> {
    SimpleViewComponent<UIImageView>().update {
      $0.kf.setImage(with: url)
    }
  }
}
