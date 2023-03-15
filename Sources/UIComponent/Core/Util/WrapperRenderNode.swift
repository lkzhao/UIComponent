//
//  File.swift
//  
//
//  Created by Luke Zhao on 3/14/23.
//

import Foundation

public protocol WrapperRenderNode: RenderNode {
    var child: RenderNode { get }
}

public extension WrapperRenderNode {
    var size: CGSize {
        child.size
    }

    var positions: [CGPoint] {
        [.zero]
    }

    var children: [RenderNode] {
        [child]
    }
}
