# Architecture

Dig deep into UIComponent's internal architecture

## Overview

UIComponent has 3 main types of objects to render a UI.

##### Component

``Component`` is a tree structure that defines a UI. It has a ``Component/layout(_:)`` method that returns a ``RenderNode`` which represents the UI after layout.

##### RenderNode

``RenderNode`` is also a tree structure that holds UI informations like ``RenderNode/size``, ``RenderNode/children-85mp2``, and ``RenderNode/positions-34087``.

To render the UI, UIComponent will ask the `RenderNode` for a flat list of ``RenderNodeChild`` that should be displayed in the visible frame. 


##### RenderNodeChild
    
``RenderNodeChild`` is an intermediate tree structure that represents all of the render nodes that should be rendered onscreen. The framework will then use this information to generate a list of ``Renderable``s

##### Renderable

``Renderable`` represents a `PlatformView` that will be rendered in the view hierarchy.

On iOS/tvOS this is a `UIView`; on macOS this is an `NSView`.

### Flow chart
![](Architecture)

### Reload

The entire process from the **Component** to the **PlatformView** being rendered onscreen is called a **"reload"**. This happens when 
* Assign a new ``ComponentEngine/component``  
* Manually calling ``ComponentEngine/setNeedsReload()`` or ``ComponentEngine/reloadData(contentOffsetAdjustFn:)``
* Size of the hosting view changes.
* SafeAreaInsets of the hosting view changes.

During a reload, the ComponentEngine calls the **layout** method and cache the resulting ``RenderNode``. Then it will start the **render** process.

### Render

The process from the RenderNode to the **PlatformView** being rendered onscreen is called a **"render"**. This happens when
* Scrolled to a new position (i.e. contentOffset changes)
* During a reload.
* Manually calling ``ComponentEngine/setNeedsRender()``

The **render** process performs a **visibility test** by asking the RenderNode to provide a list of children that are visible using the `visibleChildren(in frame: CGRect)` method.

Each type of RenderNode might have a different visibility test implementation. 

``VStack``'s `RenderNode` for example, uses binary search to find a list of child RenderNodes that are visible in the provided frame.

For a RenderNode that represents a view, it will just return an empty array.

The framework will then generates a list of ``Renderable``s from the resulting ``RenderNodeChild`` array.

### Display

With a list of Renderables, ComponentEngine then tries to **display** them onscreen. The ComponentEngine performs a diff algorithm that synchronize the subview list with the Renderable list. 

Each Renderable links to its corresponding RenderNode. If the view is not on screen yet, it will call the RenderNode's ``RenderNode/makeView()-6puft`` to generate a new PlatformView. If the view is already onscreen, it calls the ``RenderNode/updateView(_:)-2xjz4`` method to update the view to the latest state.

Renderable also contains the frame of the view that should be displayed onscreen. The ComponentEngine will use this frame to set the view's frame.

Once the views have been inserted to the view hierarchy, the entire process is finished.

> There are some concepts that are omitted for simplicity. For example, like how views are reused, and how animations are performed.
