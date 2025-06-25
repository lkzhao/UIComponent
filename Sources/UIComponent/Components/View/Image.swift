//  Created by Luke Zhao on 8/23/20.

import UIKit

/// An image component that renders an UIImageView
public struct Image: Component {
    enum Source {
        case custom(UIImage)
        case systemImage(systemName: String, configuration: UIImage.Configuration?)

        func getImage(_ font: UIFont) -> UIImage {
            switch self {
            case let .custom(uIImage):
                return uIImage
            case let .systemImage(systemName, configuration):
                let configuration =
                    if let configuration {
                        configuration.applying(UIImage.SymbolConfiguration(font: font))
                    } else {
                        UIImage.SymbolConfiguration(font: font)
                    }
                var uIImage: UIImage {
                    #if DEBUG
                    if let systemImage = UIImage(systemName: systemName, withConfiguration: configuration) {
                        return systemImage
                    } else {
                        let error = "Image should be initialized with a valid system image name. System image named \(systemName) not found."
                        fatalError(error)
                    }
                    #else
                    return UIImage(systemName: systemName, withConfiguration: configuration) ?? UIImage()
                    #endif
                }
                return uIImage
            }
        }
    }

    /// The foreground color to use when displaying this image tint color
    @Environment(\.foregroundColor) var foregroundColor

    /// The font to use when displaying this systemImage font
    @Environment(\.font) var font

    /// The underlying `UIImage` instance.
    public var image: UIImage {
        source.getImage(font)
    }
    
    let source: Source

    /// Initializes an `Image` component with the name of an image asset.
    /// - Parameter imageName: The name of the image asset to load.
    /// - Note: In DEBUG mode, if the image is not found, an assertion failure is triggered.
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

    /// Initializes an `Image` component with an `ImageResource`.
    /// - Parameter resource: The `ImageResource` to load the image from.
    @available(iOS 17.0, *)
    public init(_ resource: ImageResource) {
        self.init(UIImage(resource: resource))
    }

    /// Initializes an `Image` component with the name of a system image (SFSymbol).
    /// - Parameters:
    ///   - systemName: The name of the system image to load.
    ///   - configuration: The configuration to use for the system image.
    /// - Note: In DEBUG mode, if the system image is not found, an assertion failure is triggered.
    public init(systemName: String, withConfiguration configuration: UIImage.Configuration? = nil) {
        self.source = .systemImage(systemName: systemName, configuration: configuration)
    }

    /// Initializes an `Image` component with a `UIImage` instance.
    /// - Parameter image: The `UIImage` instance to use for the component.
    public init(_ image: UIImage) {
        self.source = .custom(image)
    }

    /// Calculates the layout for the image within the given constraints and returns an `ImageRenderNode`.
    /// - Parameter constraint: The constraints to use for sizing the image.
    /// - Returns: An `ImageRenderNode` that represents the laid out image.
    public func layout(_ constraint: Constraint) -> ImageRenderNode {
        ImageRenderNode(image: image,
                        foregroundColor: foregroundColor,
                        size: image.size.boundWithAspectRatio(to: constraint))
    }
}

/// A render node that represents an image.
public struct ImageRenderNode: RenderNode {
    /// The image to be rendered.
    public let image: UIImage
    /// The foregroundColor to render the tintColor
    public let foregroundColor: UIColor?
    /// The size to render the image.
    public let size: CGSize

    /// Updates the given image view with the render node's image.
    /// - Parameter view: The image view to update.
    public func updateView(_ view: UIImageView) {
        view.image = image
        if let foregroundColor {
            view.tintColor = foregroundColor
        }
    }
}
