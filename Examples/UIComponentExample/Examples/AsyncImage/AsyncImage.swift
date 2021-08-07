//  Created by Luke Zhao on 6/14/21.

import UIComponent
import UIKit
import Kingfisher

public struct AsyncImage: ViewComponentBuilder {
  public let url: URL
  public let indicatorType: IndicatorType
  public let options: KingfisherOptionsInfo?
  
  public init(_ url: URL,
              indicatorType: IndicatorType = .none,
              options: KingfisherOptionsInfo? = nil) {
    self.url = url
    self.indicatorType = indicatorType
    self.options = options
  }
  
  public init?(_ urlString: String,
               indicatorType: IndicatorType = .none,
               options: KingfisherOptionsInfo? = nil) {
    guard let url = URL(string: urlString) else { return nil }
    self.url = url
    self.indicatorType = indicatorType
    self.options = options
  }
  
  public func build() -> ViewUpdateComponent<SimpleViewComponent<UIImageView>> {
    SimpleViewComponent<UIImageView>().update {
      $0.kf.indicatorType = indicatorType
      $0.kf.setImage(with: url, options: options)
    }
  }
}
