//
//  File.swift
//  
//
//  Created by y H on 2021/7/25.
//

import UIKit

public struct Badge: Component {
    
    static let halfOffset = CGVector(dx: 0, dy: 0)
    
    let child: Component
    let overlay: Component
    let verticalAlignment: CrossAxisAlignment
    let horizontalAlignment: CrossAxisAlignment
    let offset: CGVector
    public func layout(_ constraint: Constraint) -> Renderer {
        let childRenderer = child.layout(constraint)
        let badgeRenderer = overlay.layout(Constraint(minSize: CGSize(width: horizontalAlignment == .stretch ? childRenderer.size.width : -.infinity ,
                                                                      height: verticalAlignment == .stretch ? childRenderer.size.height : -.infinity) ,
                                                      maxSize: childRenderer.size))
        let beagePosition: (x: CGFloat, y: CGFloat)
        switch horizontalAlignment {
        case .start:
            beagePosition.x = 0
        case .end:
            beagePosition.x = (childRenderer.size.width - badgeRenderer.size.width)
        case .center:
            beagePosition.x =  (childRenderer.size.width / 2 - badgeRenderer.size.width / 2)
        case .stretch:
            beagePosition.x = 0
        }
        switch verticalAlignment {
        case .start:
            beagePosition.y = 0
        case .end:
            beagePosition.y = (childRenderer.size.height - badgeRenderer.size.height)
        case .center:
            beagePosition.y = (childRenderer.size.height / 2 - badgeRenderer.size.height / 2)
        case .stretch:
            beagePosition.y = 0
        }
        let finallyBadgePosition = CGPoint(x: beagePosition.x, y: beagePosition.y) + offset
        
        return SlowRenderer(size: childRenderer.size, children: [childRenderer, badgeRenderer], positions: [.zero, finallyBadgePosition])
    }
}

public extension Component {
    func badge(_ component: Component,
               verticalAlignment: CrossAxisAlignment = .start,
               horizontalAlignment: CrossAxisAlignment = .end,
               offset: CGVector = .zero) -> Badge {
        Badge(child: self,
              overlay: component,
              verticalAlignment: verticalAlignment,
              horizontalAlignment: horizontalAlignment,
              offset: offset)
    }
}
