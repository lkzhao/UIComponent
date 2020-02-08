//
//  File 2.swift
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
