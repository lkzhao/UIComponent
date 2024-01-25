# Animation

Learn how to animate view transitions

## Overview

UIComponent allows you to configure an ``Animator`` object to the ``CompoenentView`` or at the individual Component level to animate view transitions. Whenever a view is inserted, deleted, or its frame got updated, the animator will be called to perform the corresponding animation. 

There is also a built-in ``Animator`` called ``TransformAnimator`` which you can use directly.

```swift
componentView.animator = TransformAnimator(transform: CATransform3DMakeScale(0.5, 0.5, 1), duration: 0.4)
```

Then whenever a cell is removed or inserted from the componentView, it will be animated with a scale transform.
TransformAnimator also performs update animation whenever the frame of a view changes.

To configure the animator on the individual component level, use the ``Component/animator(_:)`` modifier.

```swift
componentView.component = VStack {
    Text("Animated text").animator(TransformAnimator(transform: CATransform3DMakeTranslation(0, 100, 0), duration: 0.4))
    Text("Not animated text")
}
```

In this case only the "Animated text" will run the translation animation when it becomes visible.

> `TransformAnimator` doesn't animate the first reload, it only animated the subsequent updates.

#### One off animation
You can also use the following modifiers to configure custom animation without creating an animator.

@Links(visualStyle: list) {
- ``Component/animateInsert(_:)``
- ``Component/animateDelete(_:)``
- ``Component/animateUpdate(passthrough:_:)``
}

```swift
Text("Animated Insert/Delete/Update")
    .animateInsert { componentView, view, frame in
        view.alpha = 0.0
        UIView.animate(withDuration: 0.3) {
            view.alpha = 1.0
        }
    }
    .animateDelete { componentView, view, completion in
        UIView.animate(withDuration: 0.3) {
            view.alpha = 0.0
        } completion: { _ in
            completion()
        }
    }
    .animateUpdate { componentView, view, frame in
        UIView.animate(withDuration: 0.3) {
            view.frame = frame
        }
    }
```

### Custom Animator

To create a custom animator, implement the following 3 methods and perform the corresponding animation when needed.

@Links(visualStyle: list) {
- ``Animator/insert(componentView:view:frame:)-9g90``
- ``Animator/delete(componentView:view:completion:)-umbr``
- ``Animator/update(componentView:view:frame:)-15tud``
}

Example fade animator:

```swift
struct FadeAnimator: Animator {
    let duration: TimeInterval

    init(duration: TimeInterval = 0.3) {
        self.duration = duration
    }
    
    func delete(componentView: ComponentDisplayableView, view: UIView,
                                completion: @escaping () -> Void) {
        if  // Only animate when the componentView's component is updated, not when scrolling.
            componentView.isReloading, 
            // only animate if the view is deleted visibly on screen. Drop the animation if the cell is not visible.
            componentView.bounds.intersects(view.frame) {
            UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction], animations: {
                view.alpha = 0
            }, completion: { _ in
                completion()
            })
        } else {
            completion()
        }
    }
    
    func insert(componentView: ComponentDisplayableView, view: UIView, frame: CGRect) {
        view.bounds.size = frame.bounds.size
        view.center = frame.center
        if  // Only animate when the componentView's component is updated, not when scrolling.
            componentView.isReloading,
            // don't animate the first reload
            componentView.hasReloaded, 
            // only animate if the view is inserted visibly on screen. Drop the animation if the cell is not visible.
            componentView.bounds.intersects(frame)
        {
            view.alpha = 0
            UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction], animations: {
                view.alpha = 1
            })
        }
    }
}
```

Checkout `TransformAnimator.swift` to see further example of how to implement a custom animator.

