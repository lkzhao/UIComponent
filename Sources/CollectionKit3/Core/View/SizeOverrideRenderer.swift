//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

struct SizeOverrideRenderer: Renderer {
  let child: Renderer
  let size: CGSize
  func views(in frame: CGRect) -> [Renderable] {
    child.views(in: frame)
  }
}
