//
//  File.swift
//
//
//  Created by Luke Zhao on 8/23/20.
//

import Foundation

public protocol ComponentArrayContainer {
    var components: [Component] { get }
}

public struct ForEach<S: Sequence, D>: ComponentArrayContainer where S.Element == D {
    public let components: [Component]
    
    public init(_ data: S, @ComponentArrayBuilder _ content: (D) -> [Component]) {
        components = data.flatMap { content($0) }
    }
    
    private init(components: [Component]) {
        self.components = components
    }
}
