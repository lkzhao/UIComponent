# Architecture

Dig deep into UIComponent's internal architecture

## Overview

UIComponent has 3 main types of objects to render a UI.

* ``Component``
* ``RenderNode``
* ``Renderable``

Component defines the UI in a tree structure. The system calls its ``Component/layout(_:)`` method to get a ``RenderNode`` that represents the UI after layout.

The ``RenderNode`` is also a tree structure that holds informations like ``RenderNode/size``, ``RenderNode/children-85mp2``, and ``RenderNode/positions-34087`` of each of its `children`. `RenderNode` can also represent a `UIView` that will be rendered.

When the system tries to render the UI, it will ask the `RenderNode` for a flat list of ``Renderable`` that should be displayed in the visible frame. 

Each ``Renderable`` represents a `UIView` that will be rendered in the view hierarchy.

