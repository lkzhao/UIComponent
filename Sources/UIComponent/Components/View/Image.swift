//  Created by Luke Zhao on 8/23/20.

#if os(macOS)
import AppKit
#endif

/// An image component that renders a platform image view.
public struct Image: Component {
    /// The underlying platform image.
    public let image: PlatformImage

    /// Initializes an `Image` component with the name of an image asset.
    /// - Parameter imageName: The name of the image asset to load.
    /// - Note: In DEBUG mode, if the image is not found, an assertion failure is triggered.
    public init(_ imageName: String) {
#if DEBUG
        #if canImport(UIKit)
        if let image = PlatformImage(named: imageName) {
            self.init(image)
        } else {
            let error = "Image should be initialized with a valid image name. Image named \(imageName) not found."
            assertionFailure(error)
            self.init(PlatformImage())
        }
        #else
        if let image = PlatformImage(named: NSImage.Name(imageName)) {
            self.init(image)
        } else {
            let error = "Image should be initialized with a valid image name. Image named \(imageName) not found."
            assertionFailure(error)
            self.init(PlatformImage())
        }
        #endif
#else
        #if canImport(UIKit)
        self.init(PlatformImage(named: imageName) ?? PlatformImage())
        #else
        self.init(PlatformImage(named: NSImage.Name(imageName)) ?? PlatformImage())
        #endif
#endif
        
    }

    /// Initializes an `Image` component with an `ImageResource`.
    /// - Parameter resource: The `ImageResource` to load the image from.
    @available(iOS 17.0, macOS 14.0, *)
    public init(_ resource: ImageResource) {
        self.init(PlatformImage(resource: resource))
    }

    /// Initializes an `Image` component with the name of a system image (SFSymbol).
    /// - Parameters:
    ///   - systemName: The name of the system image to load.
    ///   - configuration: The configuration to use for the system image.
    /// - Note: In DEBUG mode, if the system image is not found, an assertion failure is triggered.
    public init(systemName: String, withConfiguration configuration: PlatformImageConfiguration? = nil) {
#if DEBUG
        #if canImport(UIKit)
        if let systemImage = PlatformImage(systemName: systemName, withConfiguration: configuration) {
            self.init(systemImage)
        } else {
            let error = "Image should be initialized with a valid system image name. System image named \(systemName) not found."
            assertionFailure(error)
            self.init(PlatformImage())
        }
        #else
        if let base = PlatformImage(systemSymbolName: systemName, accessibilityDescription: nil) {
            if let configuration {
                self.init(base.withSymbolConfiguration(configuration) ?? base)
            } else {
                self.init(base)
            }
        } else {
            let error = "Image should be initialized with a valid system image name. System image named \(systemName) not found."
            assertionFailure(error)
            self.init(PlatformImage())
        }
        #endif
#else
        #if canImport(UIKit)
        self.init(PlatformImage(systemName: systemName, withConfiguration: configuration) ?? PlatformImage())
        #else
        if let base = PlatformImage(systemSymbolName: systemName, accessibilityDescription: nil) {
            if let configuration {
                self.init(base.withSymbolConfiguration(configuration) ?? base)
            } else {
                self.init(base)
            }
        } else {
            self.init(PlatformImage())
        }
        #endif
#endif
        
    }

    /// Initializes an `Image` component with a platform image.
    /// - Parameter image: The platform image to use for the component.
    public init(_ image: PlatformImage) {
        self.image = image
    }

    /// Calculates the layout for the image within the given constraints and returns an `ImageRenderNode`.
    /// - Parameter constraint: The constraints to use for sizing the image.
    /// - Returns: An `ImageRenderNode` that represents the laid out image.
    public func layout(_ constraint: Constraint) -> ImageRenderNode {
        ImageRenderNode(image: image, size: image.size.boundWithAspectRatio(to: constraint))
    }
}

/// A render node that represents an image.
public struct ImageRenderNode: RenderNode {
    /// The image to be rendered.
    public let image: PlatformImage
    /// The size to render the image.
    public let size: CGSize
    
    /// Updates the given image view with the render node's image.
    /// - Parameter view: The image view to update.
    public func updateView(_ view: PlatformImageView) {
        view.image = image
    }
}
