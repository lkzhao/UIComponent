//  Created by Luke Zhao on 6/14/21.

import Kingfisher
import UIComponent
import UIKit

public struct AsyncImage: ViewComponentBuilder {
  public enum SourceType {
    // MARK: Member Cases

    /// The target image should be got from network remotely. The associated `Resource`
    /// value defines detail information like image URL and cache key.
    case network(Kingfisher.Resource?)

    /// The target image should be provided in a data format. Normally, it can be an image
    /// from local storage or in any other encoding format (like Base64).
    case provider(Kingfisher.ImageDataProvider)
  }

  public typealias AsyncIndicatorType = IndicatorType
  public typealias ConfigurationBuilder = (KF.Builder) -> KF.Builder

  public let source: SourceType
  public let indicatorType: AsyncIndicatorType
  public let configurationBuilder: ConfigurationBuilder?

  public init(
    _ source: SourceType,
    indicatorType: AsyncIndicatorType = .activity,
    configurationBuilder: ConfigurationBuilder? = nil
  ) {
    self.source = source
    self.indicatorType = indicatorType
    self.configurationBuilder = configurationBuilder
  }

  public init(
    _ url: URL?,
    indicatorType: AsyncIndicatorType = .activity,
    configurationBuilder: ConfigurationBuilder? = nil
  ) {
    self.source = .network(url)
    self.indicatorType = indicatorType
    self.configurationBuilder = configurationBuilder
  }

  public init(
    _ urlString: String,
    indicatorType: AsyncIndicatorType = .activity,
    configurationBuilder: ConfigurationBuilder? = nil
  ) {
    self.source = .network(URL(string: urlString))
    self.indicatorType = indicatorType
    self.configurationBuilder = configurationBuilder
  }

  public init(
    _ provider: ImageDataProvider,
    indicatorType: AsyncIndicatorType = .activity,
    configurationBuilder: ConfigurationBuilder? = nil
  ) {
    self.source = .provider(provider)
    self.indicatorType = indicatorType
    self.configurationBuilder = configurationBuilder
  }

  public func build() -> ViewUpdateComponent<SimpleViewComponent<UIImageView>> {
    SimpleViewComponent<UIImageView>()
      .update {
        $0.kf.indicatorType = indicatorType
        if let configurationBuilder = configurationBuilder {
          switch source {
          case .provider(let provider):
            configurationBuilder(KF.dataProvider(provider)).set(to: $0)
          case .network(let url):
            configurationBuilder(KF.resource(url)).set(to: $0)
          }
        } else {
          switch source {
          case .provider(let provider):
            KF.dataProvider(provider).set(to: $0)
          case .network(let url):
            KF.resource(url).set(to: $0)
          }
        }
      }
  }
}
