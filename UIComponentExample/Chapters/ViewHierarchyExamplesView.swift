//
//  ViewHierarchyExamplesView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/6/25.
//

import UIComponent

class ViewHierarchyExamplesView: UIView {
    override func updateProperties() {
        super.updateProperties()
        
        componentEngine.component = VStack(spacing: 40) {
            Text("Understanding View Hierarchy", font: .title)
            
            VStack(spacing: 10) {
                Text("How UIComponent creates views", font: .subtitle)
                VStack(spacing: 8) {
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "rectangle.compress.vertical")
                            .tintColor(.systemBlue)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Component tree is flattened by default", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "eye.slash")
                            .tintColor(.systemGreen)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Layout components don't generate views", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "square.stack.3d.up")
                            .tintColor(.systemOrange)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Views by defaults are siblings, not nested", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.turn.down.right")
                            .tintColor(.systemPurple)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Use .view() to create parent-child", font: .body)
                    }
                }.inset(h: 16, v: 10).backgroundColor(.systemGray6).cornerRadius(12)
            }
            
            VStack(spacing: 10) {
                Text("Default behavior: Flattened hierarchy", font: .subtitle)
                Text("Layout components like VStack and HStack don't create views by default. They only position their children. All child views end up as siblings in a flat hierarchy.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6) {
                        Text("Example: Basic VStack", font: .bodyBold)
                        Text("This VStack contains two Text components. Since no view properties are applied to the VStack, it doesn't generate a view.", font: .body).textColor(.secondaryLabel)
                        
                        #CodeExample(
                            VStack(spacing: 8) {
                                Text("Hello")
                                Text("World")
                            }
                        )

                        Code {
                            """
                            // View Hierarchy:
                            // ↳ UILabel(text: "Hello")
                            // ↳ UILabel(text: "World")
                            //
                            // Note: VStack doesn't create a view - the labels are siblings
                            """
                        }
                    }
                }
            }
            
            VStack(spacing: 10) {
                Text("Applying view properties to layouts", font: .subtitle)
                Text("When you apply view properties like backgroundColor or cornerRadius to a layout component, UIComponent creates a UIView for that layout. However, this view is placed underneath the children as a sibling, not as a parent.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6) {
                        Text("Example: VStack with backgroundColor", font: .bodyBold)
                        Text("The blue background view is created as a sibling placed below the text labels, not as their parent.", font: .body).textColor(.secondaryLabel)
                        
                        #CodeExampleNoInsets(
                            VStack(spacing: 8) {
                                Text("Hello")
                                Text("World")
                            }
                            .inset(12)
                            .backgroundColor(.systemBlue)
                            .cornerRadius(12)
                        )

                        Code {
                            """
                            // View Hierarchy:
                            // ↳ UIView(backgroundColor: .systemBlue, cornerRadius: 12)
                            // ↳ UILabel(text: "Hello")
                            // ↳ UILabel(text: "World")
                            //
                            // The background view is positioned first(underneath),
                            // then the labels are positioned on top of it
                            """
                        }
                    }
                }
            }
            
            VStack(spacing: 10) {
                Text("The .view() modifier", font: .subtitle)
                Text("Use the .view() modifier to explicitly create a parent view container that wraps its children. This creates a true parent-child relationship in the view hierarchy.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6) {
                        Text("Example: VStack wrapped with .view()", font: .bodyBold)
                        Text("Now the background view becomes a parent container, and the text labels are its children.", font: .body).textColor(.secondaryLabel)
                        
                        #CodeExampleNoInsets(
                            VStack(spacing: 8) {
                                Text("Hello")
                                Text("World")
                            }
                            .inset(12)
                            .view() // wraps children in a container view
                            .backgroundColor(.systemBlue) // applied to container
                            .cornerRadius(12)
                        )
                        Code {
                            """
                            // View Hierarchy:
                            // ↳ UIView(backgroundColor: .systemBlue, cornerRadius: 12)
                            //   ↳ UILabel(text: "Hello")
                            //   ↳ UILabel(text: "World")
                            //
                            // The labels are now children of the blue background view
                            """
                        }
                    }
                }
            }
            
            VStack(spacing: 10) {
                Text("Multi-layered nesting", font: .subtitle)
                Text("You can use .view() multiple times to create multi-layered nested views. This is particularly useful for effects like shadows with clipping.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6) {
                        Text("Example: Card with shadow and clipping", font: .bodyBold)
                        Text("Shadows require clipsToBounds to be false, while rounded corners need it to be true. The solution is to use multiple view layers.", font: .body).textColor(.secondaryLabel)
                        
                        #CodeExample(
                            VStack(spacing: 10) {
                                Text("Card Title", font: .bodyBold)
                                Text("This card has both rounded corners and a shadow, which requires two separate view layers.", font: .body)
                                    .textColor(.secondaryLabel)
                            }
                            .inset(20)
                            .view()                  // Inner view for clipping
                            .backgroundColor(.systemBackground)
                            .cornerRadius(16)
                            .clipsToBounds(true)
                            .view()                  // Outer view for shadow
                            .with(\.layer.shadowColor, UIColor.black.cgColor)
                            .with(\.layer.shadowOpacity, 0.15)
                            .with(\.layer.shadowOffset, CGSize(width: 0, height: 4))
                            .with(\.layer.shadowRadius, 12)
                        )
                        
                        Code {
                            """
                            // View Hierarchy:
                            // ↳ UIView(shadow properties)
                            //   ↳ UIView(background, cornerRadius, clipsToBounds)
                            //     ↳ UILabel(text: "Card Title")
                            //     ↳ UILabel(text: "Content...")
                            """
                        }
                    }
                }
            }
            
            VStack(spacing: 10) {
                Text("Other view wrapper modifiers", font: .subtitle)
                Text("Several modifiers create view wrappers similar to .view(). These include .scrollView() and .tappableView(). They all create parent-child relationships.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6) {
                        Text(".scrollView() example", font: .bodyBold)
                        
                        #CodeExampleNoInsets(
                            VStack(spacing: 4) {
                                for i in 1...20 {
                                    Text("Item \(i)")
                                        .inset(12)
                                }
                            }
                            .scrollView()
                            .size(height: 200)
                        )

                        Code {
                            """
                            // View Hierarchy:
                            // ↳ UIScrollView(wrapping all content)
                            //   ↳ UILabel(text: "Item 1")
                            //   ↳ UILabel(text: "Item 2")
                            //   ↳ ...
                            """
                        }
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text(".tappableView() example", font: .bodyBold)
                        
                        #CodeExampleNoInsets(
                            HStack(spacing: 10, alignItems: .center) {
                                Image(systemName: "star.fill")
                                    .tintColor(.systemYellow)
                                Text("Tap me!")
                            }
                            .inset(h: 20, v: 12)
                            .backgroundColor(.systemGray6)
                            .cornerRadius(8)
                            .tappableView {
                                print("Tapped!")
                            }
                        )

                        Code {
                            """
                            // View Hierarchy:
                            // ↳ TappableView(gesture handlers)
                            //   ↳ UIImageView(image: star.fill)
                            //   ↳ UILabel(text: "Tap me!")
                            """
                        }
                    }
                }
            }
            
            VStack(spacing: 10) {
                Text("Modifier order matters", font: .subtitle)
                Text("The order in which you apply modifiers significantly affects the view hierarchy. This is especially important with .inset() and view-generating modifiers.", font: .body).textColor(.secondaryLabel)

                VStack(spacing: 15) {
                    VStack(spacing: 6) {
                        Text("Example: inset before vs after backgroundColor", font: .bodyBold)
                        Text("These two produce different results because of modifier order.", font: .body).textColor(.secondaryLabel)
                        
                        HStack(spacing: 20) {
                            VStack(spacing: 8, alignItems: .center) {
                                Text("Order 1", font: .caption).textColor(.secondaryLabel)
                                Text("Spacious", font: .body)
                                    .inset(10)
                                    .backgroundColor(.systemBlue.withAlphaComponent(0.2))
                            }
                            
                            VStack(spacing: 8, alignItems: .center) {
                                Text("Order 2", font: .caption).textColor(.secondaryLabel)
                                Text("Compact", font: .body)
                                    .backgroundColor(.systemGreen.withAlphaComponent(0.2))
                                    .inset(10)
                            }
                        }.inset(20)
                        
                        Code {
                            """
                            // Order 1: inset then backgroundColor
                            Text("Hello")
                                .inset(10)
                                .backgroundColor(.systemBlue)
                            
                            // View Hierarchy:
                            // ↳ UIView(backgroundColor: .systemBlue, Spacious - 10pt larger than UILabel)
                            // ↳ UILabel(text: "Hello", positioned 10pt from edges)
                            """
                        }
                        Code {
                            """
                            // Order 2: backgroundColor then inset
                            Text("Hello")
                                .backgroundColor(.systemBlue)
                                .inset(10)
                            
                            // View Hierarchy:
                            // ↳ UILabel(text: "Hello", backgroundColor: .systemBlue, positioned 10pt from edges)
                            // 
                            // There is only a single view, since the backgroundColor applied directly to the label
                            // without a layout component in between.
                            """
                        }
                    }
                }
            }
            
            VStack(spacing: 10) {
                Text("⚠️ Gotcha: clipsToBounds with sibling views", font: .subtitle)
                Text("A common mistake is expecting clipsToBounds to work on layout components without .view(). Since the background view is a sibling, it can't clip the children.", font: .body).textColor(.systemRed)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6) {
                        Text("❌ Won't clip properly", font: .bodyBold).textColor(.systemRed)
                        Text("The overflow view extends beyond the rounded corners because the background is a sibling, not a parent.", font: .body).textColor(.systemRed)
                        
                        #CodeExample(
                            HStack(justifyContent: .start) {
                                Space(width: 100, height: 50)
                                    .backgroundColor(.systemBlue)
                                    .overlay {
                                        Text("Overflows").textColor(.white).textAlignment(.center)
                                    }
                                // This deliberately overflows to show the issue
                                Space(width: 40, height: 50)
                                    .backgroundColor(.systemRed)
                                    .offset(x: -20)
                            }
                            .backgroundColor(.systemGray5)
                            .clipsToBounds(true)
                            .cornerRadius(16)
                            .size(width: 150, height: 50)
                        )
                        
                        Code {
                            """
                            // Problem: Doesn't clip children
                            // ↳ UIView(cornerRadius, clipsToBounds) - sibling
                            // ↳ UIView(blue) - sibling, not clipped
                            """
                        }
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text("✅ Clips correctly", font: .bodyBold).textColor(.systemGreen)
                        Text("Using .view() creates a parent container that can properly clip its children.", font: .body).textColor(.systemGreen)
                        
                        #CodeExample(
                            HStack(justifyContent: .start) {
                                Space(width: 100, height: 50)
                                    .backgroundColor(.systemBlue)
                                    .overlay {
                                        Text("Clipped").textColor(.white).textAlignment(.center)
                                    }
                                Space(width: 40, height: 50)
                                    .backgroundColor(.systemRed)
                                    .offset(x: -20)
                            }
                            .view()
                            .backgroundColor(.systemGray5)
                            .clipsToBounds(true)
                            .cornerRadius(16)
                            .size(width: 150, height: 50)
                        )
                        
                        Code {
                            """
                            HStack {
                                Space(width: 100, height: 50)
                                    .backgroundColor(.systemBlue)
                            }
                            .view()
                            .clipsToBounds(true)
                            .cornerRadius(16)
                            
                            // Fixed: Children are properly clipped
                            // ↳ UIView(cornerRadius, clipsToBounds) - parent
                            //   ↳ UIView(blue) - child, gets clipped
                            """
                        }
                    }
                }
                .inset(16)
                .backgroundColor(.systemRed.withAlphaComponent(0.1))
                .cornerRadius(12)
            }
            
            VStack(spacing: 10) {
                Text("⚠️ Gotcha: Animators and view boundaries", font: .subtitle)
                Text("Animators have two common issues related to view hierarchy: they may only apply to the background view instead of the entire component, and they don't cross view boundaries.", font: .body).textColor(.systemOrange)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6) {
                        Text("Issue 1: Animator only affects background", font: .bodyBold).textColor(.systemOrange)
                        Text("When you apply an animator to a layout component without .view(), only the background view animates, not the children.", font: .body).textColor(.secondaryLabel)
                        
                        Code {
                            """
                            // ❌ Problem: Only background animates
                            HStack {
                                Text("Hello")
                            }
                            .backgroundColor(.systemBlue)
                            .animator(TransformAnimator(...))
                            
                            // The text doesn't animate with the background because
                            // the animator is only applied to the background view(sibling)
                            
                            // ✅ Solution: Use .view() to wrap everything
                            HStack {
                                Text("Hello")
                            }
                            .view()
                            .backgroundColor(.systemBlue)
                            .animator(TransformAnimator(...))
                            
                            // Now the entire view container animates together,
                            // including the text as its child
                            """
                        }
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text("Issue 2: Animators don't cross view boundaries", font: .bodyBold).textColor(.systemOrange)
                        Text("When you use view wrapper modifiers like .view(), .scrollView(), or .tappableView(), they create a new view boundary. The parent's componentEngine animator doesn't apply to children inside these wrapped views.", font: .body).textColor(.secondaryLabel)
                        
                        Code {
                            """
                            // ❌ Problem: Animator on parent doesn't apply to wrapped child
                            VStack {
                                Text("I won't animate")
                                    .view()
                                    .backgroundColor(.systemBlue)
                            }
                            .with(\\.componentEngine.animator, TransformAnimator(...))
                            
                            // The .view() creates a boundary, so the text won't animate
                            
                            // ✅ Solution: Apply animator to the wrapped view directly
                            VStack {
                                Text("I will animate")
                                    .view()
                                    .backgroundColor(.systemBlue)
                                    .animator(TransformAnimator(...))
                            }
                            
                            // Or use .with(\\.componentEngine.animator) on the child
                            VStack {
                                Text("I will also animate")
                                    .view()
                                    .backgroundColor(.systemBlue)
                                    .with(\\.componentEngine.animator, TransformAnimator(...))
                            }
                            """
                        }
                    }
                }
                .inset(16)
                .backgroundColor(.systemOrange.withAlphaComponent(0.1))
                .cornerRadius(12)
            }
            
            VStack(spacing: 10) {
                Text("⚠️ Gotcha: View ID across boundaries", font: .subtitle)
                Text("View IDs don't work across view boundaries. When you wrap a component with .view() or other view wrappers, the ID of inner components is no longer accessible to the outer componentEngine.", font: .body).textColor(.systemPurple)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6) {
                        Text("Problem: Can't access inner view ID", font: .bodyBold).textColor(.systemPurple)
                        Text("Methods like visibleView(id:) and frame(id:) won't find IDs inside wrapped views.", font: .body).textColor(.secondaryLabel)
                        
                        Code {
                            """
                            // ❌ Problem: Can't find "innerView" from parent
                            VStack {
                                Text("Hello")
                                    .id("innerView")
                                    .view()
                                    .backgroundColor(.systemBlue)
                            }
                            
                            // From parent componentEngine:
                            let view = componentEngine.visibleView(id: "innerView")
                            // Returns nil because .view() creates a boundary
                            
                            // ✅ Solution: Apply ID to the outer view wrapper
                            VStack {
                                Text("Hello")
                                    .view()
                                    .backgroundColor(.systemBlue)
                                    .id("outerView")  // ID on wrapper
                            }
                            
                            // Now this works:
                            let view = componentEngine.visibleView(id: "outerView")
                            // Returns the UIView wrapper
                            """
                        }
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text("Best practice", font: .bodyBold)
                        Text("Always apply .id() to the outermost view wrapper, not to inner components that are already wrapped.", font: .body).textColor(.secondaryLabel)
                        
                        Code {
                            """
                            // ✅ Good: ID on outermost wrapper
                            VStack {
                                Text("Content")
                            }
                            .scrollView()
                            .id("myScrollView")  // ID here
                            
                            // ✅ Good: ID on tappable wrapper
                            Text("Tap me")
                                .tappableView { }
                                .id("myButton")  // ID here
                            
                            // ❌ Bad: ID hidden inside wrapper
                            Text("Can't find me")
                                .id("hidden")  // This ID won't be accessible
                                .tappableView { }
                            """
                        }
                    }
                }
                .inset(16)
                .backgroundColor(.systemPurple.withAlphaComponent(0.1))
                .cornerRadius(12)
            }
            
            VStack(spacing: 10) {
                Text("Best practices", font: .subtitle)
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "1.circle.fill")
                            .tintColor(.systemBlue)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Understand the default behavior", font: .bodyBold)
                            Text("Remember that layout components create flat hierarchies by default. Views are siblings, not nested.", font: .body).textColor(.secondaryLabel)
                        }.flex()
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "2.circle.fill")
                            .tintColor(.systemGreen)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Use .view() intentionally", font: .bodyBold)
                            Text("Only use .view() when you need true parent-child relationships for clipping, shadows, or grouped animations.", font: .body).textColor(.secondaryLabel)
                        }.flex()
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "3.circle.fill")
                            .tintColor(.systemOrange)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Be mindful of modifier order", font: .bodyBold)
                            Text("The order of modifiers matters. Experiment to understand how different orderings produce different results.", font: .body).textColor(.secondaryLabel)
                        }.flex()
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "4.circle.fill")
                            .tintColor(.systemPurple)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Apply IDs to outer wrappers", font: .bodyBold)
                            Text("Always put .id() modifiers on the outermost view wrapper to ensure they're accessible to the parent componentEngine.", font: .body).textColor(.secondaryLabel)
                        }.flex()
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "5.circle.fill")
                            .tintColor(.systemPink)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Respect view boundaries", font: .bodyBold)
                            Text("Remember that animators and other componentEngine settings don't cross view wrapper boundaries.", font: .body).textColor(.secondaryLabel)
                        }.flex()
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "6.circle.fill")
                            .tintColor(.systemIndigo)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Multi-layer when needed", font: .bodyBold)
                            Text("For complex effects like shadows with clipping, don't hesitate to use multiple .view() layers.", font: .body).textColor(.secondaryLabel)
                        }.flex()
                    }
                }
                .inset(16)
                .backgroundColor(.secondarySystemBackground)
                .cornerRadius(12)
            }
            
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}

