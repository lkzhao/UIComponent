//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct Image: ViewComponent {
  public let image: UIImage
  
  public init(_ imageName: String) {
    self.init(UIImage(named: imageName)!)
  }
  @available(iOS 13.0, *)
  public init(systemName: String) {
    self.init(UIImage(systemName: systemName) ?? UIImage())
  }
  public init(_ image: UIImage) {
    self.image = image
  }

  public func layout(_ constraint: Constraint) -> ImageRenderer {
    ImageRenderer(image: image, size: image.size.bound(to: constraint))
  }
}

public struct ImageRenderer: ViewRenderer {
  public let image: UIImage
  public let size: CGSize
  public func updateView(_ view: UIImageView) {
    view.image = image
  }
}
