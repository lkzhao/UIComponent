//  Created by Luke Zhao on 8/23/20.

import Foundation

public struct Join: ComponentArrayContainer {
  public let components: [Component]
  
  public init(@ComponentArrayBuilder _ content: () -> [Component], @ComponentArrayBuilder separator: () -> [Component]) {
    var result: [Component] = []
    let components = content()
    for i in 0..<components.count - 1 {
      result.append(components[i])
      result.append(contentsOf: separator())
    }
    if let lastComponent = components.last {
      result.append(lastComponent)
    }
    self.components = result
  }
}
