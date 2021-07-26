//
//  FlexColumn.swift
//  
//
//  Created by Luke Zhao on 7/18/21.
//

import UIKit

public struct FlexColumn: FlexLayoutComponent, HorizontalLayoutProtocol {
    public var lineSpacing: CGFloat
    public var interitemSpacing: CGFloat
    
    public var alignContent: MainAxisAlignment
    public var alignItems: CrossAxisAlignment
    public var justifyContent: MainAxisAlignment
    public var tailJustifyContent: MainAxisAlignment?
    public var children: [Component]
    
    public init(lineSpacing: CGFloat = 0,
                interitemSpacing: CGFloat = 0,
                justifyContent: MainAxisAlignment = .start,
                alignItems: CrossAxisAlignment = .start,
                alignContent: MainAxisAlignment = .start,
                children: [Component]) {
        self.lineSpacing = lineSpacing
        self.interitemSpacing = interitemSpacing
        self.justifyContent = justifyContent
        self.alignItems = alignItems
        self.alignContent = alignContent
        self.children = children
    }
}

