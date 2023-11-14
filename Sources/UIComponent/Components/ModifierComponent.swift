//
//  File.swift
//  
//
//  Created by Luke Zhao on 6/25/23.
//

import Foundation

public struct ModifierComponent<Content: Component, Result: RenderNode>: Component where Content.R.View == Result.View {
    let content: Content
    let modifier: (Content.R) -> Result

    public func layout(_ constraint: Constraint) -> Result {
        modifier(content.layout(constraint))
    }
}
