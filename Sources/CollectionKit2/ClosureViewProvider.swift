//
//  ClosureViewProvider.swift
//  CollectionKit2
//
//  Created by Luke Zhao on 2019-01-07.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

import UIKit

open class ClosureViewProvider<View: UIView>: BaseViewProvider<View> {
	public typealias ViewGenerator = () -> View
	public typealias ViewUpdater = (View) -> Void
	public typealias SizeGenerator = (CGSize) -> CGSize

	public var viewGenerator: ViewGenerator?
	public var viewUpdater: ViewUpdater?
	public var sizeSource: SizeGenerator?

	public init(key: String = UUID().uuidString,
				animator: Animator? = nil,
				reuseManager: CollectionReuseManager? = nil,
				generate: ViewGenerator? = nil,
				update: ViewUpdater?,
				size: SizeGenerator?) {
        super.init(key: key, animator: animator, reuseManager: reuseManager)
		self.viewGenerator = generate
		self.viewUpdater = update
		self.sizeSource = size
	}
    
    open override func updateView(_ view: View) {
        viewUpdater?(view)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return sizeSource?(size) ?? .zero
    }
    
    open override func makeView() -> View {
        return viewGenerator?() ?? View()
    }
}

open class BaseViewProvider<View: UIView>: ViewProvider {
    public var key: String
    public var animator: Animator?
    public var reuseManager: CollectionReuseManager?
    
    public init(key: String = UUID().uuidString,
                animator: Animator? = nil,
                reuseManager: CollectionReuseManager? = nil) {
        self.key = key
        self.animator = animator
        self.reuseManager = reuseManager
    }
    
    // MARK: - Subclass override

    open func sizeThatFits(_ size: CGSize) -> CGSize {
        return .zero
    }
    
    open func updateView(_ view: View) {
        
    }

    open func makeView() -> View {
        return View()
    }
    
    // MARK: - View Provider

    public func makeView() -> UIView {
        return reuseManager?.dequeue(makeView()) ?? makeView()
    }

    public func updateView(_ view: UIView) {
        guard let view = view as? View else { return }
        updateView(view)
    }

    // MARK: - Provider

    public func layout(size: CGSize) -> CGSize {
        _size = sizeThatFits(size)
        return _size
    }

    public func views(in frame: CGRect) -> [(ViewProvider, CGRect)] {
        let childFrame = CGRect(origin: .zero, size: _size)
        if frame.intersects(childFrame) {
            return [(self, childFrame)]
        }
        return []
    }

    // MARK: - Private

    var _size: CGSize = .zero
}
