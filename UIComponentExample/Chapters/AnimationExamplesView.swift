//  Created by Luke Zhao on 11/5/25.

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIComponent

class AnimationExamplesView: UIView {
    struct ListItem: Identifiable {
        let id: String = UUID().uuidString
        let index: Int
    }
    
    @Observable
    class AnimationViewModel {
        var showItem: Bool = true
        var items: [String] = ["Item 1", "Item 2", "Item 3"]
        var animatedItems: [String] = ["A", "B", "C"]
        var cascadeItems: [UUID] = Array(1...10).map { _ in UUID() }
        var enableCascade: Bool = false
        var customAnimItems: [String] = ["Alpha", "Beta", "Gamma"]
        var updateAnimationFrame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 40)
        var sharedItems: [ListItem] = [
            ListItem(index: 1),
            ListItem(index: 2),
            ListItem(index: 3),
        ]
        var sharedItemNextIndex: Int = 4
    }
    
    let viewModel = AnimationViewModel()

    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        componentEngine.component = VStack(spacing: 40) {
            Text("Animation Examples", font: .title)
            
            VStack(spacing: 10) {
                Text("What is an Animator?", font: .subtitle)
                Text("UIComponent allows you to configure an Animator to animate view transitions. Whenever a view is inserted, deleted, or its frame is updated, the animator performs the corresponding animation.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 8) {
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.up.right")
                            .tintColor(.systemGreen)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Insert animations - fade in, scale, slide", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.down.left")
                            .tintColor(.systemRed)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Delete animations - fade out, shrink", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.left.arrow.right")
                            .tintColor(.systemBlue)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Update animations - smooth transitions", font: .body)
                    }
                }.inset(h: 16, v: 10).backgroundColor(.systemGray6).cornerRadius(12)
            }
            
            VStack(spacing: 10) {
                Text("TransformAnimator basics", font: .subtitle)
                Text("TransformAnimator is the built-in animator that applies transform and fade animations during insertion and deletion. It also animates frame changes on updates.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Toggle Item", font: .body)
                        .inset(h: 20, v: 10)
                        .backgroundColor(.systemBlue)
                        .textColor(.white)
                        .cornerRadius(8)
                        .tappableView {
                            viewModel.showItem.toggle()
                        }
                    #CodeExampleNoInsets(
                        ZStack {
                            if viewModel.showItem {
                                Text("I'm animated!", font: .body)
                                    .inset(h: 20, v: 10)
                                    .view()
                                    .backgroundColor(.systemGreen)
                                    .textColor(.white)
                                    .cornerRadius(8)
                                    .animator(TransformAnimator(transform: CATransform3DMakeScale(0.5, 0.5, 1)))
                            }
                        }.size(width: 240, height: 100)
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Transform types", font: .subtitle)
                Text("TransformAnimator supports any CATransform3D. Here are common examples:", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Scale transform", font: .caption)

                    HStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Text("Add", font: .caption)
                                .inset(h: 10, v: 6)
                                .backgroundColor(.systemBlue)
                                .textColor(.white)
                                .cornerRadius(4)
                                .tappableView {
                                    viewModel.animatedItems.append("Item \(viewModel.animatedItems.count + 1)")
                                }

                            if !viewModel.animatedItems.isEmpty {
                                Text("Remove", font: .caption)
                                    .inset(h: 10, v: 6)
                                    .backgroundColor(.systemRed)
                                    .textColor(.white)
                                    .cornerRadius(4)
                                    .tappableView {
                                        viewModel.animatedItems.removeLast()
                                    }
                            }
                        }
                    }

                    #CodeExample(
                        Flow(spacing: 8) {
                            for item in viewModel.animatedItems {
                                Text(item, font: .body)
                                    .inset(h: 12, v: 8)
                                    .view()
                                    .backgroundColor(.systemGreen)
                                    .cornerRadius(6)
                                    .animator(TransformAnimator(transform: CATransform3DMakeScale(0.3, 0.3, 1)))
                            }
                        }
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Translation transform", font: .subtitle)
                Text("Slide items in from different directions using CATransform3DMakeTranslation.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Slide from bottom", font: .caption)
                    HStack(spacing: 8) {
                        Text("Add", font: .caption)
                            .inset(h: 10, v: 6)
                            .backgroundColor(.systemBlue)
                            .textColor(.white)
                            .cornerRadius(4)
                            .tappableView {
                                viewModel.items.append("Item \(viewModel.items.count + 1)")
                            }

                        if !viewModel.items.isEmpty {
                            Text("Remove", font: .caption)
                                .inset(h: 10, v: 6)
                                .backgroundColor(.systemRed)
                                .textColor(.white)
                                .cornerRadius(4)
                                .tappableView {
                                    viewModel.items.removeLast()
                                }
                        }
                    }
                    #CodeExample(
                        VStack(spacing: 8) {
                            for item in viewModel.items {
                                Text(item, font: .body)
                                    .inset(h: 16, v: 8)
                                    .view()
                                    .backgroundColor(.systemIndigo)
                                    .textColor(.white)
                                    .cornerRadius(6)
                                    .animator(TransformAnimator(transform: CATransform3DMakeTranslation(100, 0, 0)))
                            }
                        }
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Cascade animations", font: .subtitle)
                Text("The cascade property creates staggered animations based on item position. Items further from the origin animate with a slight delay, creating a wave effect.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    HStack(spacing: 10, alignItems: .center) {
                        ViewComponent<MySwitch>()
                            .isOn(viewModel.enableCascade)
                            .onTintColor(.systemGreen)
                            .onToggle {
                                viewModel.enableCascade = $0
                                viewModel.cascadeItems = Array(1...10).map { _ in UUID() }
                            }
                            .id("cascadeSwitch")
                            .size(width: 62, height: 30)
                        Text("Cascade: \(viewModel.enableCascade ? "ON" : "OFF")", font: .caption)
                    }
                    
                    #CodeExample(
                        VStack(spacing: 8) {
                            for (i, id) in viewModel.cascadeItems.enumerated() {
                                Text("Item \(i)", font: .body)
                                    .inset(h: 16, v: 10)
                                    .view()
                                    .backgroundColor(.systemPurple)
                                    .textColor(.white)
                                    .cornerRadius(6)
                                    .id(id.uuidString)
                                    .animator(TransformAnimator(
                                        transform: CATransform3DMakeTranslation(200, 0, 0),
                                        duration: 0.5,
                                        cascade: viewModel.enableCascade
                                    ))
                            }
                        }
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Global animator", font: .subtitle)
                Text("Set animator on componentEngine.animator to apply animations to all components. This affects all view insertions, deletions, and updates within that view.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Setting global animator", font: .caption)
                    Code {
                        """
                        // In your view or view controller
                        view.componentEngine.animator = TransformAnimator(
                            transform: CATransform3DMakeScale(0.5, 0.5, 1),
                            duration: 0.4
                        )
                        
                        // Now all components will use this animator
                        view.componentEngine.component = VStack {
                            for item in items {
                                Text(item)  // These will all animate automatically
                            }
                        }
                        """
                    }
                }
            }
            
            VStack(spacing: 10) {
                Text("Component-level animator", font: .subtitle)
                Text("Use .animator() modifier to apply animations to specific components only, overriding the global animator.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Example with mixed animators", font: .caption)
                    Code {
                        """
                        VStack {
                            // This item uses scale animation
                            Text("Scales in")
                                .animator(TransformAnimator(
                                    transform: CATransform3DMakeScale(0.5, 0.5, 1),
                                    duration: 0.4
                                ))
                            
                            // This item uses slide animation
                            Text("Slides in")
                                .animator(TransformAnimator(
                                    transform: CATransform3DMakeTranslation(0, 100, 0),
                                    duration: 0.4
                                ))
                            
                            // This item has no animation
                            Text("No animation")
                        }
                        """
                    }
                }
            }
            
            VStack(spacing: 10) {
                Text("One-off animation modifiers", font: .subtitle)
                Text("Use animateInsert(), animateDelete(), and animateUpdate() modifiers for custom animations without creating an Animator struct.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Text("Add", font: .caption)
                            .inset(h: 10, v: 6)
                            .backgroundColor(.systemBlue)
                            .textColor(.white)
                            .cornerRadius(4)
                            .tappableView {
                                viewModel.customAnimItems.append("Item \(viewModel.customAnimItems.count + 1)")
                            }
                        
                        if !viewModel.customAnimItems.isEmpty {
                            Text("Remove", font: .caption)
                                .inset(h: 10, v: 6)
                                .backgroundColor(.systemRed)
                                .textColor(.white)
                                .cornerRadius(4)
                                .tappableView {
                                    viewModel.customAnimItems.removeLast()
                                }
                        }
                    }
                    
                    #CodeExample(
                        VStack(spacing: 8) {
                            for item in viewModel.customAnimItems {
                                Text(item, font: .body)
                                    .inset(h: 16, v: 10)
                                    .view()
                                    .backgroundColor(.systemOrange)
                                    .textColor(.white)
                                    .cornerRadius(6)
                                    .animateInsert { hostingView, view, frame in
                                        view.bounds.size = frame.size
                                        view.center = CGPoint(x: frame.midX, y: frame.midY)
                                        view.alpha = 0
                                        view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
                                            view.alpha = 1
                                            view.transform = .identity
                                        }
                                    }
                                    .animateDelete { hostingView, view, completion in
                                        UIView.animate(withDuration: 0.3) {
                                            view.alpha = 0
                                            view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                                        } completion: { _ in
                                            completion()
                                        }
                                    }
                            }
                        }
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Update animations", font: .subtitle)
                Text("TransformAnimator automatically animates frame changes when components update. Use animateUpdate() for custom frame transition animations or create your own animator", font: .body).textColor(.secondaryLabel)

                #CodeExampleNoInsets(
                    ZStack {
                        Text("Tap to move and resize the blue box", font: .caption)
                            .textColor(.secondaryLabel)
                            .offset(y: -130)
                        Space(size: viewModel.updateAnimationFrame.size)
                            .backgroundColor(.systemBlue)
                            .cornerRadius(8)
                            .animateUpdate { hostingView, view, frame in
                                UIView.animate(withDuration: 0.3) {
                                    view.frame = frame
                                }
                            }
                            .offset(viewModel.updateAnimationFrame.origin)
                    }
                    .size(width: 400, height: 300)
                    .tappableView {
                        let tapLocation = $0.tapGestureRecognizer.location(in: $0)
                        let newWidth = CGFloat.random(in: 80...200)
                        let newHeight = CGFloat.random(in: 30...100)
                        let newOffsetX = tapLocation.x - $0.bounds.midX
                        let newOffsetY = tapLocation.y - $0.bounds.midY
                        viewModel.updateAnimationFrame = CGRect(
                            x: newOffsetX,
                            y: newOffsetY,
                            width: newWidth,
                            height: newHeight
                        )
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("Custom Animator", font: .subtitle)
                Text("Create your own animator by conforming to the Animator protocol. Implement insert(), delete(), and update() methods for complete control.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Example: FadeAnimator", font: .caption)
                    Code(FadeAnimator.codeRepresentation)

                    Text("Usage", font: .caption)
                    Code {
                        """
                        view.componentEngine.animator = FadeAnimator(duration: 0.5)
                        """
                    }
                }
            }

            VStack(spacing: 10) {
                Text("Animator Common Issues", font: .subtitle)
                VStack(spacing: 10) {
                    VStack(spacing: 6) {
                        Text("Issue 1: id not assigned", font: .bodyBold)
                        Text("If a component doesn't have a stable id, UIComponent cannot track it across updates, leading to unexpected animation behavior. Always assign unique ids to animatable components.", font: .body).textColor(.secondaryLabel)
                        
                        Text("❌ Without id: Wrong item animates", font: .caption).textColor(.systemRed)
                        Text("Tap any item to delete it. Notice how the animation happens on the wrong item because UIComponent can't track which item was removed.", font: .caption).textColor(.secondaryLabel)
                        #CodeExampleNoInsets(
                            VStack(spacing: 8, alignItems: .stretch) {
                                for (i, item) in viewModel.sharedItems.enumerated() {
                                    Text("Item \(item.index): Tap to Delete", font: .body)
                                        .inset(h: 16, v: 10)
                                        .tappableView {
                                            viewModel.sharedItems.remove(at: i)
                                        }
                                        .backgroundColor(.systemGray6)
                                        .cornerRadius(8)
                                        // ❌ No .id() modifier - UIComponent can't track items
                                }
                                Text("Add Item")
                                    .textAlignment(.center)
                                    .inset(h: 16, v: 10)
                                    .tappableView {
                                        viewModel.sharedItems.append(ListItem(index: viewModel.sharedItemNextIndex))
                                        viewModel.sharedItemNextIndex += 1
                                    }
                                    .backgroundColor(.systemBlue)
                                    .cornerRadius(8)
                            }
                            .inset(10)
                            .scrollView()
                            .with(\.componentEngine.animator, TransformAnimator(transform: CATransform3DMakeScale(0.5, 0.5, 1.0)))
                            .size(width: 240, height: 280)
                        )
                        
                        Text("✅ With id: Correct item animates", font: .caption).textColor(.systemGreen)
                        Text("Now each item has a unique id. The correct item animates out when deleted.", font: .caption).textColor(.secondaryLabel)
                        #CodeExampleNoInsets(
                            VStack(spacing: 8, alignItems: .stretch) {
                                for (i, item) in viewModel.sharedItems.enumerated() {
                                    Text("Item \(item.index): Tap to Delete", font: .body)
                                        .inset(h: 16, v: 10)
                                        .tappableView {
                                            viewModel.sharedItems.remove(at: i)
                                        }
                                        .backgroundColor(.systemGray6)
                                        .cornerRadius(8)
                                        .id(item.id) // ✅ Unique id allows proper tracking
                                }
                                Text("Add Item")
                                    .textAlignment(.center)
                                    .inset(h: 16, v: 10)
                                    .tappableView {
                                        viewModel.sharedItems.append(ListItem(index: viewModel.sharedItemNextIndex))
                                        viewModel.sharedItemNextIndex += 1
                                    }
                                    .backgroundColor(.systemBlue)
                                    .cornerRadius(8)
                                    .id("addButton") // Same for the add button
                            }
                            .inset(10)
                            .scrollView()
                            .with(\.componentEngine.animator, TransformAnimator(transform: CATransform3DMakeScale(0.5, 0.5, 1.0)))
                            .size(width: 240, height: 280)
                        )
                    }

                    Separator()

                    VStack(spacing: 4) {
                        Text("Issue 2: Animator doesn't cross view boundary", font: .bodyBold)
                        Text("Components that are wrapped in view wrapper modifiers like .view(), .scrollView(), .tappableView(), etc... create a new view boundary. Animators set on parent views do not propagate across these boundaries. To ensure animations work as expected, set the animator on the specific component.", font: .body).textColor(.secondaryLabel)
                        ChapterLink(
                            title: "See View Hierarchy chapter for more details.",
                            viewType: ViewHierarchyExamplesView.self,
                            anchorId: "animator-issues"
                        )
                    }

                    Separator()

                    VStack(spacing: 4) {
                        Text("Issue 3: Wrap components to animate together", font: .bodyBold)
                        Text("When assigning animators, wrap multiple components into a single .view() to ensure they animate together as a group. Especially when modifiers like .insets() are applied. This allows the animator to treat them as a single unit during insertions, deletions, and updates.", font: .body).textColor(.secondaryLabel)
                        ChapterLink(
                            title: "See View Hierarchy chapter for more details.",
                            viewType: ViewHierarchyExamplesView.self,
                            anchorId: "animator-issues"
                        )
                    }
                }
                .inset(16)
                .backgroundColor(.systemOrange.withAlphaComponent(0.1))
                .cornerRadius(12)
            }

            VStack(spacing: 10) {
                Text("Best practices", font: .subtitle)
                VStack(spacing: 8) {
                    VStack(spacing: 4) {
                        Text("1. Check isReloading", font: .bodyBold)
                        Text("Only animate during component updates, not during scroll operations. Use hostingView.componentEngine.isReloading to check.", font: .body).textColor(.secondaryLabel)
                    }
                    
                    VStack(spacing: 4) {
                        Text("2. Check hasReloaded", font: .bodyBold)
                        Text("Skip animations on the first reload using hostingView.componentEngine.hasReloaded to avoid animating initial content.", font: .body).textColor(.secondaryLabel)
                    }
                    
                    VStack(spacing: 4) {
                        Text("3. Check bounds intersection", font: .bodyBold)
                        Text("Only animate views that are visible on screen using hostingView.bounds.intersects(frame) for better performance.", font: .body).textColor(.secondaryLabel)
                    }
                    
                    VStack(spacing: 4) {
                        Text("4. Use spring animations", font: .bodyBold)
                        Text("Spring animations feel more natural. Use UIView.animate with usingSpringWithDamping for bouncy, organic motion.", font: .body).textColor(.secondaryLabel)
                    }
                    
                    VStack(spacing: 4) {
                        Text("5. Keep durations short", font: .bodyBold)
                        Text("Animations should be quick (0.2-0.5s). Longer durations can make your UI feel sluggish.", font: .body).textColor(.secondaryLabel)
                    }
                    
                    VStack(spacing: 4) {
                        Text("6. Always call completion", font: .bodyBold)
                        Text("In delete animations, always call the completion block when done. UIComponent needs this to clean up views properly.", font: .body).textColor(.secondaryLabel)
                    }
                }.inset(16).backgroundColor(.systemBlue.withAlphaComponent(0.1)).cornerRadius(12)
            }
            
            VStack(spacing: 10) {
                Text("Practical example: Animated list", font: .subtitle)
                Text("Combine everything to create a fully animated list with add/remove interactions.", font: .body).textColor(.secondaryLabel)
                ViewComponent<AnimatedListExample>()
                    .size(width: 360, height: 300)
                Code(AnimatedListExample.codeRepresentation)
            }
            
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always)
            .with(\.componentEngine.visibleFrameInsets, UIEdgeInsets(top: -400, left: 0, bottom: -400, right: 0))
            .with(\.componentEngine.animator, TransformAnimator(transform: CATransform3DMakeScale(0.5, 0.5, 1)))
            .fill()
    }
}
@GenerateCode
struct FadeAnimator: Animator {
    let duration: TimeInterval

    init(duration: TimeInterval = 0.3) {
        self.duration = duration
    }

    func insert(hostingView: UIView, view: UIView, frame: CGRect) {
        view.bounds.size = frame.size
        view.center = CGPoint(x: frame.midX, y: frame.midY)

        // Only animate when component is reloading
        if hostingView.componentEngine.isReloading,
           // Don't animate the first reload
           hostingView.componentEngine.hasReloaded,
           // Only animate visible views
           hostingView.bounds.intersects(frame) {
            view.alpha = 0
            UIView.animate(withDuration: duration) {
                view.alpha = 1
            }
        }
    }

    func delete(hostingView: UIView, view: UIView,
               completion: @escaping () -> Void) {
        if hostingView.componentEngine.isReloading,
           hostingView.bounds.intersects(view.frame) {
            UIView.animate(withDuration: duration) {
                view.alpha = 0
            } completion: { _ in
                completion()
            }
        } else {
            completion()
        }
    }

    func update(hostingView: UIView, view: UIView, frame: CGRect) {
        UIView.animate(withDuration: duration) {
            view.frame = frame
        }
    }
}

@GenerateCode
class AnimatedListExample: UIView {
    struct Fruit: Identifiable, Hashable {
        let id: UUID = UUID()
        let name: String
    }

    @Observable
    class ListViewModel {
        var items: [Fruit] = [
            Fruit(name: "Apple"),
            Fruit(name: "Banana"),
            Fruit(name: "Cherry"),
            Fruit(name: "Date"),
            Fruit(name: "Elderberry")
        ]
        var nextId: Int = 6
    }
    
    let viewModel = ListViewModel()
    
    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        
        componentEngine.component = VStack(alignItems: .stretch) {
            // Header
            HStack(spacing: 10, alignItems: .center) {
                Text("Animated List", font: .bodyBold)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .tintColor(.systemGreen)
                    .contentMode(.scaleAspectFit)
                    .size(width: 24, height: 24)
                    .tappableView {
                        let fruits = ["Fig", "Grape", "Honeydew", "Kiwi", "Lemon", "Mango", "Orange", "Papaya"]
                        viewModel.items.insert(Fruit(name: fruits.randomElement()!), at: 0)
                    }
            }
            .inset(16)
            .backgroundColor(.systemGray6)
            
            Separator()
            
            // List items
            VStack(alignItems: .stretch) {
                for (index, item) in viewModel.items.enumerated() {
                    HStack(spacing: 12, alignItems: .center) {
                        Image(systemName: "circle.fill")
                            .tintColor(.systemBlue)
                            .contentMode(.scaleAspectFit)
                            .size(width: 8, height: 8)

                        Text(item.name, font: .body)
                            .flex()

                        Image(systemName: "trash")
                            .tintColor(.systemRed)
                            .contentMode(.scaleAspectFit)
                            .size(width: 20, height: 20)
                            .tappableView {
                                viewModel.items.remove(at: index)
                            }
                    }
                    .inset(h: 16, v: 12)
                    .view()
                    .id(item.id.uuidString)
                    .animator(TransformAnimator(transform: CATransform3DMakeTranslation(300, 0, 0)))
                }
            }
            .scrollView()
            .with(\.componentEngine.visibleFrameInsets, UIEdgeInsets(top: -200, left: 0, bottom: -200, right: 0))
            .fill()
            .flex()
        }
        .view()
        .clipsToBounds(true)
        .backgroundColor(.systemBackground)
        .cornerRadius(12)
        .borderWidth(1)
        .borderColor(.systemGray4)
    }
}

#endif
