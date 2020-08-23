//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

public struct Renderable {
  public var id: String
  public var animator: Animator?
  public var renderer: AnyViewRenderer
  public var frame: CGRect
}
