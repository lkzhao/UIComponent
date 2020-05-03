//
//  Image.swift
//  
//
//  Created by Luke Zhao on 2/5/20.
//

import UIKit

public class Image: ViewAdapter<UIImageView> {
  var image: UIImage
  public convenience init(_ imageName: String) {
    self.init(UIImage(named: imageName)!)
  }
  @available(iOS 13.0, *)
  public convenience init(systemName: String) {
    self.init(UIImage(systemName: systemName) ?? UIImage())
  }
  public init(_ image: UIImage) {
    self.image = image
    super.init()
  }
  public override func updateView(_ view: UIImageView) {
    view.image = image
    super.updateView(view)
  }
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    return image.size
  }
}
