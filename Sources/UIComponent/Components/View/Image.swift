//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct Image: ViewComponent {
  public let image: UIImage

  public init(_ imageName: String) {
    self.init(UIImage(named: imageName)!)
  }

  public init(systemName: String, withConfiguration configuration: UIImage.Configuration? = nil) {
      self.init(UIImage(systemName: systemName, withConfiguration: configuration) ?? UIImage())
  }

  public init(_ image: UIImage) {
    self.image = image
  }

  public func layout(_ constraint: Constraint) -> ImageRenderNode {
    ImageRenderNode(image: image, size: image.size.bound(to: constraint))
  }
}

public struct ImageRenderNode: ViewRenderNode {
  public let image: UIImage
  public let size: CGSize
  public func updateView(_ view: UIImageView) {
    view.image = image
  }
}
