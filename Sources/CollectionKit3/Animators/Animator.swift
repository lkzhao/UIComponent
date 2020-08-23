//
//  CollectionAnimator.swift
//  CollectionView
//
//  Created by Luke Zhao on 2017-07-19.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class Animator {
	/// Called before CollectionView perform any update to the cells.
	/// This method is only called when your animator is the collectionView's root animator (i.e. collectionView.animator)
	///
	/// - Parameters:
	///   - collectionView: the CollectionView performing the update
	open func willUpdate(collectionView _: ComponentDisplayableView) {}

	/// Called when CollectionView inserts a view into its subviews.
	///
	/// Perform any insertion animation when needed
	///
	/// - Parameters:
	///   - collectionView: source CollectionView
	///   - view: the view being inserted
	///   - at: index of the view inside the CollectionView (after flattening step)
	///   - frame: frame provided by the layout
	open func insert(collectionView _: ComponentDisplayableView,
									 view _: UIView,
									 frame _: CGRect) {}

	/// Called when CollectionView deletes a view from its subviews.
	///
	/// Perform any deletion animation, then call `enqueue(view: view)`
	/// after the animation finishes
	///
	/// - Parameters:
	///   - collectionView: source CollectionView
	///   - view: the view being deleted
	open func delete(collectionView _: ComponentDisplayableView,
									 view: UIView) {
		view.recycleForCollectionKitReuse()
	}

	/// Called when:
	///   * the view has just been inserted
	///   * the view's frame changed after `reloadData`
	///   * the view's screen position changed when user scrolls
	///
	/// - Parameters:
	///   - collectionView: source CollectionView
	///   - view: the view being updated
	///   - at: index of the view inside the CollectionView (after flattening step)
	///   - frame: frame provided by the layout
	open func update(collectionView _: ComponentDisplayableView,
									 view: UIView,
									 frame: CGRect) {
		if view.bounds.size != frame.bounds.size {
			view.bounds.size = frame.bounds.size
		}
		if view.center != frame.center {
			view.center = frame.center
		}
	}

	/// Called when contentOffset changes during reloadData
	///
	/// - Parameters:
	///   - collectionView: source CollectionView
	///   - delta: changes in contentOffset
	///   - view: the view being updated
	///   - at: index of the view inside the CollectionView (after flattening step)
	///   - frame: frame provided by the layout
	open func shift(collectionView _: ComponentDisplayableView,
									delta: CGPoint,
									view: UIView,
									frame _: CGRect) {
		view.center += delta
	}

	public init() {}
}
