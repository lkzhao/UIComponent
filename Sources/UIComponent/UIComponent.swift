//  Created by Luke Zhao on 12/30/25.

@_exported import Foundation
@_exported import QuartzCore
@_exported import ObjectiveC

#if canImport(UIKit)
@_exported import UIKit

public typealias PlatformView = UIView
public typealias PlatformImage = UIImage
public typealias PlatformColor = UIColor
public typealias PlatformFont = UIFont
public typealias PlatformBezierPath = UIBezierPath
public typealias PlatformEdgeInsets = UIEdgeInsets
public typealias PlatformScrollView = UIScrollView
public typealias PlatformEvent = UIEvent
public typealias PlatformImageView = UIImageView
public typealias PlatformImageConfiguration = UIImage.Configuration
public typealias PlatformLabel = UILabel
public typealias PlatformMenu = UIMenu
public typealias PlatformRectEdge = UIRectEdge

#if os(tvOS)
public struct PlatformPointerStyle {}
#else
@available(iOS 13.4, *)
public typealias PlatformPointerStyle = UIPointerStyle
#endif

public typealias PlatformLongPressGesture = UILongPressGestureRecognizer

#if !os(tvOS)
public typealias PlatformDropOperation = UIDropOperation

public struct PlatformDropInfo {
    public let interaction: UIDropInteraction
    public let session: UIDropSession

    public init(interaction: UIDropInteraction, session: UIDropSession) {
        self.interaction = interaction
        self.session = session
    }
}
#endif

#elseif canImport(AppKit)
@_exported import AppKit

public typealias PlatformView = NSView
public typealias PlatformImage = NSImage
public typealias PlatformColor = NSColor
public typealias PlatformFont = NSFont
public typealias PlatformBezierPath = NSBezierPath
public typealias PlatformEdgeInsets = NSEdgeInsets
public typealias PlatformEvent = NSEvent
public typealias PlatformImageView = NSImageView
public typealias PlatformImageConfiguration = NSImage.SymbolConfiguration
public typealias PlatformLabel = NSTextField
public typealias PlatformMenu = NSMenu

public typealias PlatformPointerStyle = NSCursor

public final class PlatformLongPressGesture {
    public enum State {
        case possible
        case began
        case changed
        case ended
        case cancelled
        case failed
    }

    public var state: State

    public init(state: State = .possible) {
        self.state = state
    }
}

public typealias PlatformDropOperation = NSDragOperation

public struct PlatformDropInfo {
    public let draggingInfo: NSDraggingInfo

    public init(draggingInfo: NSDraggingInfo) {
        self.draggingInfo = draggingInfo
    }
}

public struct PlatformRectEdge: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let top = PlatformRectEdge(rawValue: 1 << 0)
    public static let left = PlatformRectEdge(rawValue: 1 << 1)
    public static let bottom = PlatformRectEdge(rawValue: 1 << 2)
    public static let right = PlatformRectEdge(rawValue: 1 << 3)
}
#endif
