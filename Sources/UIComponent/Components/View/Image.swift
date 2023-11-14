//  Created by Luke Zhao on 8/23/20.

import UIKit

public struct Image: Component {
    public let image: UIImage

    public init(_ imageName: String) {
#if DEBUG
        if let image = UIImage(named: imageName) {
            self.init(image)
        } else {
            let error = "Image should be initialized with a valid image name. Image named \(imageName) not found."
            assertionFailure(error)
            self.init(UIImage())
        }
#else
        self.init(UIImage(named: imageName) ?? UIImage())
#endif
        
    }

    public init(systemName: String, withConfiguration configuration: UIImage.Configuration? = nil) {
#if DEBUG
        if let systemImage = UIImage(systemName: systemName, withConfiguration: configuration) {
            self.init(systemImage)
        } else {
            let error = "Image should be initialized with a valid system image name. System image named \(systemName) not found."
            assertionFailure(error)
            self.init(UIImage())
        }
#else
        self.init(UIImage(systemName: systemName, withConfiguration: configuration) ?? UIImage())
#endif
        
        self.init(UIImage(systemName: systemName, withConfiguration: configuration) ?? UIImage())
    }

    public init(_ image: UIImage) {
        self.image = image
    }

    public func layout(_ constraint: Constraint) -> ImageRenderNode {
        ImageRenderNode(image: image, size: image.size.bound(to: constraint))
    }
}

public struct ImageRenderNode: RenderNode {
    public let image: UIImage
    public let size: CGSize
    public func updateView(_ view: UIImageView) {
        view.image = image
    }
}
