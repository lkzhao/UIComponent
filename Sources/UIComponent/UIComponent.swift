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

#elseif canImport(AppKit)
@_exported import AppKit

public typealias PlatformView = NSView
public typealias PlatformImage = NSImage
public typealias PlatformColor = NSColor
public typealias PlatformFont = NSFont
public typealias PlatformBezierPath = NSBezierPath
public typealias PlatformEdgeInsets = NSEdgeInsets
public typealias PlatformEvent = NSEvent
#endif
