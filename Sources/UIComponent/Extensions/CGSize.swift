//  Created by Luke Zhao on 10/17/21.

@_implementationOnly import BaseToolbox
import CoreGraphics

extension CGSize {
    public static let infinity: CGSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    public static let minSize: CGSize = -.infinity
}
