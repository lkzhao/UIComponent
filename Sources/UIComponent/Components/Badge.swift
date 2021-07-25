//
//  File.swift
//  
//
//  Created by y H on 2021/7/25.
//

import UIKit

public enum BadgePosition {
    case topLeft, topRight, bottomLeft, bottomRight
}

public struct Badge: Component {
    let child: Component
    let overlay: Component
    let position: BadgePosition
    let offset: CGPoint
    public func layout(_ constraint: Constraint) -> Renderer {
        let childRenderer = child.layout(constraint)
        let badgeRenderer = overlay.layout(Constraint(minSize: .zero, maxSize: childRenderer.size))
        let beagePosition: CGPoint
        switch position {
        case .topLeft:
            let x = -(badgeRenderer.size.width / 2)
            let y = -(badgeRenderer.size.height / 2)
            beagePosition = CGPoint(x: x , y: y) + offset
        case .topRight:
            let x = childRenderer.size.width - (badgeRenderer.size.width / 2)
            let y = -(badgeRenderer.size.height / 2)
            beagePosition = CGPoint(x: x - offset.x, y: y + offset.y)
        case .bottomLeft:
            let x = -(badgeRenderer.size.width / 2)
            let y = childRenderer.size.height - (badgeRenderer.size.height / 2)
            beagePosition = CGPoint(x: x + offset.x, y: y - offset.y)
        case .bottomRight:
            let x = childRenderer.size.width - (badgeRenderer.size.width / 2)
            let y = childRenderer.size.height - (badgeRenderer.size.height / 2)
            beagePosition = CGPoint(x: x, y: y) - offset
        }
        return SlowRenderer(size: childRenderer.size, children: [childRenderer, badgeRenderer], positions: [.zero, beagePosition])
    }
}

public extension Component {
    func badge(_ component: Component, position: BadgePosition = .topRight, offset: CGPoint = .zero) -> Badge {
        Badge(child: self,
              overlay: component,
              position: position,
              offset: offset)
    }
}
