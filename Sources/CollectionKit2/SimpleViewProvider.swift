//
//  SimpleViewProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-24.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//
import UIKit

public enum SizeStrategy {
  case fill, fit, absolute(CGFloat)
  var isFit: Bool {
    switch self {
    case .fit:
      return true
    default:
      return false
    }
  }
}

/// A view provider provides a single view.
public class SimpleViewProvider<View: UIView>: ViewAdapter<View> {
	public var width: SizeStrategy
	public var height: SizeStrategy
  public var sizeProvider: ((CGSize) -> CGSize)?

	public init(id: String = UUID().uuidString,
							animator: Animator? = nil,
							width: SizeStrategy = .fit,
							height: SizeStrategy = .fit,
							view: View) {
		self.width = width
		self.height = height
    super.init(id: id, animator: animator, view: view)
	}

	public init(id: String = UUID().uuidString,
							animator: Animator? = nil,
							view: View,
							sizeProvider: @escaping (CGSize) -> CGSize) {
		self.width = .fit
		self.height = .fit
		self.sizeProvider = sizeProvider
    super.init(id: id, animator: animator, view: view)
	}

  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    if let sizeProvider = sizeProvider {
      return sizeProvider(size)
    }

    let fitSize = view?.sizeThatFits(size) ?? .zero
    var result = CGSize.zero
    switch width {
    case .fill:
      // if parent width is infinity (un specified?)
      result.width = (size.width == .infinity ? fitSize.width : size.width)
    case .fit:
      result.width = fitSize.width
    case let .absolute(value):
      result.width = value
    }

    switch height {
    case .fill:
      result.height = size.height == .infinity ? fitSize.height : size.height
    case .fit:
      result.height = fitSize.height
    case let .absolute(value):
      result.height = value
    }

    return result
  }
}
