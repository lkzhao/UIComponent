//
//  CustomComponentExamplesView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/6/25.
//

import UIComponent

class CustomComponentExamplesView: UIView {
    @Observable
    class ViewModel {
        var showAdvancedCard: Bool = false
        var flowColumnCount: Int = 3
    }
    
    let viewModel = ViewModel()
    
    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        
        componentEngine.component = VStack(spacing: 40) {
            Text("Custom Components", font: .title)
            
            VStack(spacing: 10) {
                Text("Custom components let you encapsulate reusable UI patterns into composable building blocks. You can create simple wrapper components using ComponentBuilder, or implement advanced layout logic with the Component protocol.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 8) {
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.triangle.branch")
                            .tintColor(.systemBlue)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Compose existing components", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "cube.box")
                            .tintColor(.systemGreen)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Encapsulate UI patterns", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "slider.horizontal.3")
                            .tintColor(.systemOrange)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Create custom layout logic", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .tintColor(.systemPurple)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Reusable across your app", font: .body)
                    }
                }.inset(h: 16, v: 10).backgroundColor(.systemGray6).cornerRadius(12)
            }
            
            // MARK: - ComponentBuilder Basics
            
            VStack(spacing: 10) {
                Text("Simple custom components with ComponentBuilder", font: .subtitle)
                Text("ComponentBuilder is the easiest way to create custom components. Instead of implementing layout(_:), you implement build() to return another component.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6) {
                        Text("Basic wrapper component", font: .bodyBold)
                        Text("Create a simple card component that wraps content with consistent styling.", font: .body).textColor(.secondaryLabel)
                        
                        #CodeExample(
                            Card {
                                VStack(spacing: 8) {
                                    Text("Simple Card", font: .bodyBold)
                                    Text("This is a reusable card component", font: .body)
                                        .textColor(.secondaryLabel)
                                }
                            }
                        )
                        
                        Code(Card.codeRepresentation)
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text("Component with parameters", font: .bodyBold)
                        Text("Add parameters to make your components configurable.", font: .body).textColor(.secondaryLabel)
                        
                        #CodeExample(
                            VStack(spacing: 4) {
                                PrimaryButton(title: "Save") {
                                    print("Save tapped")
                                }
                                
                                PrimaryButton(title: "Cancel", color: .systemRed) {
                                    print("Cancel tapped")
                                }
                                
                                PrimaryButton(title: "Disabled", isEnabled: false) {
                                    print("This won't print")
                                }
                            }
                        )
                        
                        Code(PrimaryButton.codeRepresentation)
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text("Component accepting child content", font: .bodyBold)
                        Text("Use @ComponentArrayBuilder to accept arbitrary child components.", font: .body).textColor(.secondaryLabel)
                        
                        #CodeExample(
                            Section(title: "User Profile") {
                                UserCard(name: "John Doe", email: "john@example.com")
                            }
                        )
                        
                        Code(Section.codeRepresentation)
                        Code(UserCard.codeRepresentation)
                    }
                }
            }
            
            // MARK: - Practical Examples
            
            VStack(spacing: 10) {
                Text("Practical wrapper components", font: .subtitle)
                Text("Here are some useful components you can create for your app.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        Text("Avatar component", font: .bodyBold)
                        #CodeExample(
                            HStack(spacing: 12) {
                                Avatar(systemImage: "person.fill", size: 40)
                                Avatar(systemImage: "star.fill", size: 50, backgroundColor: .systemYellow)
                                Avatar(systemImage: "heart.fill", size: 60, backgroundColor: .systemPink)
                            }
                        )
                        Code(Avatar.codeRepresentation)
                    }
                    
                    VStack(spacing: 6) {
                        Text("Badge component", font: .bodyBold)
                        #CodeExample(
                            HStack(spacing: 10) {
                                Badge(text: "New")
                                Badge(text: "Popular", color: .systemPurple)
                                Badge(text: "Sale", color: .systemRed)
                                Badge(text: "Premium", color: .systemOrange)
                            }
                        )
                        Code(Badge.codeRepresentation)
                    }
                    
                    VStack(spacing: 6) {
                        Text("List row component", font: .bodyBold)
                        #CodeExampleNoInsets(
                            VStack {
                                ListRow(
                                    icon: "folder.fill",
                                    title: "Documents",
                                    subtitle: "24 files"
                                )
                                Separator()
                                ListRow(
                                    icon: "photo.fill",
                                    title: "Photos",
                                    subtitle: "156 items",
                                    iconColor: .systemPink
                                )
                                Separator()
                                ListRow(
                                    icon: "music.note",
                                    title: "Music",
                                    subtitle: "42 songs",
                                    iconColor: .systemRed
                                )
                            }
                        )
                        Code(ListRow.codeRepresentation)
                    }
                }
            }
            
            // MARK: - Advanced: Constraint-based Components
            
            VStack(spacing: 10) {
                Text("Advanced: Using constraints for dynamic sizing", font: .subtitle)
                Text("When you need direct access to the constraint for calculations, use the Component protocol instead of ComponentBuilder. The layout(_:) method receives the constraint as a parameter, and you must call .layout(constraint) at the end to convert your component to a RenderNode.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6) {
                        Text("The problem", font: .bodyBold)
                        Text("You want to create a grid of items in a Flow layout where each item perfectly fills 1/3 of the width, accounting for spacing.", font: .body).textColor(.secondaryLabel)
                        
                        VStack(spacing: 8) {
                            Text("Without using constraints, your items might overflow or not fill properly:", font: .caption).textColor(.secondaryLabel)
                            #CodeExample(
                                Flow(spacing: 10) {
                                    for i in 1...9 {
                                        // ❌ These have fixed width and don't adapt
                                        Text("\(i)")
                                            .textAlignment(.center)
                                            .inset(20)
                                            .backgroundColor(.systemBlue)
                                            .cornerRadius(8)
                                            .size(width: 100, height: 80)
                                    }
                                }.backgroundColor(.systemGray6)
                            )
                        }
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text("The solution: write a custom FlowGrid component", font: .bodyBold).textColor(.systemGreen)
                        Text("Use Component protocol to get direct access to the constraint parameter in layout(_:). Calculate the item width based on columns and spacing, then wrap a Flow layout that sizes all children appropriately.", font: .body).textColor(.secondaryLabel)
                        
                        HStack(spacing: 10, alignItems: .center) {
                            Text("Columns:", font: .body)
                            ViewComponent<Slider>()
                                .minimumValue(2)
                                .maximumValue(5)
                                .value(CGFloat(viewModel.flowColumnCount))
                                .onValueChanged {
                                    viewModel.flowColumnCount = Int($0.rounded())
                                }
                                .size(width: 150, height: 30)
                            Text("\(viewModel.flowColumnCount)", font: .bodyBold)
                        }
                        .inset(h: 16, v: 12)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(12)
                        
                        #CodeExample(
                            FlowGrid(columns: viewModel.flowColumnCount, spacing: 10) {
                                for i in 1...12 {
                                    VStack(spacing: 8, justifyContent: .center, alignItems: .center) {
                                        Image(systemName: "square.fill")
                                            .tintColor(.systemBlue)
                                        Text("Item \(i)", font: .caption)
                                    }
                                    .inset(v: 20)
                                    .backgroundColor(.systemBackground)
                                    .cornerRadius(8)
                                }
                            }
                        )
                        
                        Text("How it works:", font: .caption).textColor(.secondaryLabel)
                        Code(FlowGrid.codeRepresentation)
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text("Advanced example: Responsive card", font: .bodyBold)
                        Text("A card that changes its layout based on available width.", font: .body).textColor(.secondaryLabel)
                        
                        HStack(spacing: 10, alignItems: .center) {
                            ViewComponent<MySwitch>()
                                .isOn(viewModel.showAdvancedCard)
                                .onToggle { [weak self] isOn in
                                    self?.viewModel.showAdvancedCard = isOn
                                }
                                .size(width: 62, height: 30)
                            Text("Toggle card style", font: .body)
                        }
                        
                        #CodeExampleNoInsets(
                            ResponsiveCard(
                                title: "Responsive Card",
                                description: "This card changes layout based on available width. Try toggling to see different container sizes!",
                                icon: "star.fill"
                            ).size(width: viewModel.showAdvancedCard ? .fill : .percentage(0.5))
                        )
                        
                        Code(ResponsiveCard.codeRepresentation)
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text("⚠️ Type erasure with .eraseToAnyRenderNode()", font: .bodyBold).textColor(.systemOrange)
                        Text("Notice in ResponsiveCard that we call .eraseToAnyRenderNode() on both branches. This is necessary because:", font: .body).textColor(.secondaryLabel)
                        
                        VStack(spacing: 8) {
                            VStack(spacing: 4) {
                                Text("1. Different return types", font: .bodyBold)
                                Text("The VStack branch and HStack branch produce different RenderNode types. Swift's type system requires all return paths to have the same type.", font: .body).textColor(.secondaryLabel)
                            }
                            
                            VStack(spacing: 4) {
                                Text("2. Type erasure makes them compatible", font: .bodyBold)
                                Text(".eraseToAnyRenderNode() converts any RenderNode into an AnyRenderNode, which allows all branches to return the same concrete type (AnyRenderNode).", font: .body).textColor(.secondaryLabel)
                            }
                            
                            VStack(spacing: 4) {
                                Text("3. When you need it", font: .bodyBold)
                                Text("Only needed when your layout(_:) method has conditional logic that returns different component hierarchies. If you always return the same structure, you can use 'some RenderNode'.", font: .body).textColor(.secondaryLabel)
                            }
                        }
                        .inset(12)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(8)
                        
                        Code {
                            """
                            // ❌ This won't compile - different return types
                            func layout(_ constraint: Constraint) -> some RenderNode {
                                if condition {
                                    return VStack { ... }.layout(constraint)  // VStackRenderNode
                                } else {
                                    return HStack { ... }.layout(constraint)  // HStackRenderNode
                                }
                            }
                            
                            // ✅ This works - erased to same type (AnyRenderNode)
                            func layout(_ constraint: Constraint) -> some RenderNode {
                                if condition {
                                    return VStack { ... }
                                        .layout(constraint)
                                        .eraseToAnyRenderNode()  // Returns AnyRenderNode
                                } else {
                                    return HStack { ... }
                                        .layout(constraint)
                                        .eraseToAnyRenderNode()  // Returns AnyRenderNode
                                }
                            }
                            """
                        }
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text("Other type erasure methods", font: .bodyBold)
                        Text("UIComponent provides additional type erasure methods for different use cases:", font: .body).textColor(.secondaryLabel)
                        
                        VStack(spacing: 8) {
                            VStack(spacing: 4) {
                                Text(".eraseToAnyComponent()", font: .bodyBold)
                                Text("Erases a Component to AnyComponent. Useful when you need to store or return components of different types.", font: .body).textColor(.secondaryLabel)
                            }
                            
                            VStack(spacing: 4) {
                                Text(".eraseToAnyComponentOfView()", font: .bodyBold)
                                Text("Erases a Component to AnyComponentOfView<View>. Use when you need type erasure but want to preserve the view type information.", font: .body).textColor(.secondaryLabel)
                            }
                            
                            VStack(spacing: 4) {
                                Text(".eraseToAnyRenderNode()", font: .bodyBold)
                                Text("Erases a RenderNode to AnyRenderNode. Most commonly used in layout(_:) methods with conditional returns.", font: .body).textColor(.secondaryLabel)
                            }
                            
                            VStack(spacing: 4) {
                                Text(".eraseToAnyRenderNodeOfView()", font: .bodyBold)
                                Text("Erases a RenderNode to AnyRenderNodeOfView<View>. Use when you need type erasure for RenderNodes but want to preserve the view type information.", font: .body).textColor(.secondaryLabel)
                            }
                        }
                        .inset(12)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(8)
                        
                        Code {
                            """
                            // Example: .eraseToAnyComponent() for component arrays
                            var components: [AnyComponent] = []
                            components.append(Text("Hello").eraseToAnyComponent())
                            components.append(Image(systemName: "star").eraseToAnyComponent())
                            
                            // Example: .eraseToAnyComponentOfView() preserving view type
                            func getComponent() -> AnyComponentOfView<UILabel> {
                                if condition {
                                    return Text("Option A").eraseToAnyComponentOfView()
                                } else {
                                    return Text("Option B").eraseToAnyComponentOfView()
                                }
                            }
                            
                            // Example: .eraseToAnyRenderNodeOfView() preserving view type
                            func layout(_ constraint: Constraint) -> AnyRenderNodeOfView<UILabel> {
                                if condition {
                                    return Text("Option A").layout(constraint).eraseToAnyRenderNodeOfView()
                                } else {
                                    return Text("Option B").layout(constraint).eraseToAnyRenderNodeOfView()
                                }
                            }
                            """
                        }
                    }
                }
            }
            
            // MARK: - Custom Layout Components
            
            VStack(spacing: 10) {
                Text("Creating custom layout components", font: .subtitle)
                Text("For advanced use cases, you can implement custom layout logic by conforming to the Component protocol and implementing layout(_:) directly. This gives you complete control over child positioning.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6) {
                        Text("Understanding layout(_:)", font: .bodyBold)
                        Text("The layout method receives a Constraint and must return a RenderNode. The RenderNode contains the size, children render nodes, and their positions.", font: .body).textColor(.secondaryLabel)
                        
                        Code {
                            """
                            struct MyComponent: Component {
                                func layout(_ constraint: Constraint) -> some RenderNode {
                                    // 1. Layout child components
                                    // 2. Calculate positions
                                    // 3. Return RenderNode with size, children, and positions
                                }
                            }
                            """
                        }
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text("Built-in RenderNode types", font: .bodyBold)
                        Text("UIComponent provides several RenderNode types optimized for different layouts:", font: .body).textColor(.secondaryLabel)
                        
                        VStack(spacing: 8) {
                            VStack(spacing: 4) {
                                Text("VerticalRenderNode", font: .bodyBold)
                                Text("Optimized for vertical lists. Uses binary search for visible items. Children must be sorted by Y position.", font: .caption).textColor(.secondaryLabel)
                            }
                            VStack(spacing: 4) {
                                Text("HorizontalRenderNode", font: .bodyBold)
                                Text("Optimized for horizontal lists. Uses binary search for visible items. Children must be sorted by X position.", font: .caption).textColor(.secondaryLabel)
                            }
                            VStack(spacing: 4) {
                                Text("SlowRenderNode", font: .bodyBold)
                                Text("Loops through all children to check visibility. Use when children aren't in a predictable order.", font: .caption).textColor(.secondaryLabel)
                            }
                            VStack(spacing: 4) {
                                Text("AlwaysRenderNode", font: .bodyBold)
                                Text("Renders all children always. Use for small, always-visible layouts.", font: .caption).textColor(.secondaryLabel)
                            }
                        }.inset(12).backgroundColor(.systemGray6).cornerRadius(8)
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text("Example: Custom MyVStack", font: .bodyBold)
                        Text("A simple vertical stack implementation to show how layout components work.", font: .body).textColor(.secondaryLabel)
                        
                        #CodeExample(
                            MyVStack(spacing: 10) {
                                Text("First Item", font: .bodyBold)
                                    .inset(h: 20, v: 10)
                                    .backgroundColor(.systemBlue)
                                    .cornerRadius(8)
                                
                                Text("Second Item", font: .body)
                                    .inset(h: 16, v: 8)
                                    .backgroundColor(.systemGreen)
                                    .cornerRadius(8)
                                
                                Text("Third Item with longer text", font: .caption)
                                    .inset(h: 12, v: 6)
                                    .backgroundColor(.systemOrange)
                                    .cornerRadius(8)
                            }
                        )
                        
                        Code(MyVStack.codeRepresentation)
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6) {
                        Text("Example: Custom diagonal layout", font: .bodyBold)
                        Text("A more creative layout that positions items diagonally.", font: .body).textColor(.secondaryLabel)
                        
                        #CodeExample(
                            DiagonalStack(spacing: 10, offset: 30) {
                                for i in 1...5 {
                                    Text("Item \(i)")
                                        .inset(h: 16, v: 10)
                                        .backgroundColor(.systemPurple)
                                        .textColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        )
                        
                        Code(DiagonalStack.codeRepresentation)
                    }
                }
            }
            
            // MARK: - Best Practices
            
            VStack(spacing: 10) {
                Text("Best practices", font: .subtitle)
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "1.circle.fill")
                            .tintColor(.systemBlue)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Start with ComponentBuilder", font: .bodyBold)
                            Text("Use ComponentBuilder for most cases. Only implement layout(_:) when you need custom layout logic.", font: .body).textColor(.secondaryLabel)
                        }.flex()
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "2.circle.fill")
                            .tintColor(.systemGreen)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Keep components small and focused", font: .bodyBold)
                            Text("Each component should have a single responsibility. Compose multiple small components rather than creating one large component.", font: .body).textColor(.secondaryLabel)
                        }.flex()
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "3.circle.fill")
                            .tintColor(.systemOrange)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Use structs, not classes", font: .bodyBold)
                            Text("Components should be value types (structs). This ensures they're thread-safe and work well with UIComponent's architecture.", font: .body).textColor(.secondaryLabel)
                        }.flex()
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "4.circle.fill")
                            .tintColor(.systemPurple)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Avoid capturing self in closures", font: .bodyBold)
                            Text("When using closures (like in ConstraintReader), be careful about memory management. Capture local variables instead of self when possible.", font: .body).textColor(.secondaryLabel)
                        }.flex()
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "5.circle.fill")
                            .tintColor(.systemPink)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Consider performance", font: .bodyBold)
                            Text("For components used in large lists, ensure layout calculations are efficient. Use .lazy modifier if needed.", font: .body).textColor(.secondaryLabel)
                        }.flex()
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "6.circle.fill")
                            .tintColor(.systemIndigo)
                            .size(width: 24, height: 24)
                        VStack(spacing: 4) {
                            Text("Use Environment for shared config", font: .bodyBold)
                            Text("For values used across many components (theme colors, fonts), use Environment instead of passing props through every level.", font: .body).textColor(.secondaryLabel)
                        }.flex()
                    }
                }
                .inset(16)
                .backgroundColor(.secondarySystemBackground)
                .cornerRadius(12)
            }
            
            // MARK: - When to Create Custom Components
            
            VStack(spacing: 10) {
                Text("When should you create custom components?", font: .subtitle)
                VStack(spacing: 12) {
                    VStack(spacing: 8) {
                        Text("✅ Good reasons:", font: .bodyBold).textColor(.systemGreen)
                        VStack(spacing: 4) {
                            Text("• You're repeating the same UI pattern in multiple places", font: .body)
                            Text("• You want to encapsulate complex logic", font: .body)
                            Text("• You need a custom layout algorithm", font: .body)
                            Text("• You want to make your code more testable", font: .body)
                            Text("• You're building a design system", font: .body)
                        }
                    }
                    .inset(16)
                    .backgroundColor(.systemGreen.withAlphaComponent(0.1))
                    .cornerRadius(12)
                    
                    VStack(spacing: 8) {
                        Text("❌ Avoid over-abstraction:", font: .bodyBold).textColor(.systemOrange)
                        VStack(spacing: 4) {
                            Text("• Don't create components for one-off UIs", font: .body)
                            Text("• Don't add unnecessary parameters \"just in case\"", font: .body)
                            Text("• Don't wrap every single built-in component", font: .body)
                            Text("• Don't create deep component hierarchies", font: .body)
                        }
                    }
                    .inset(16)
                    .backgroundColor(.systemOrange.withAlphaComponent(0.1))
                    .cornerRadius(12)
                }
            }
            
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}

// MARK: - Example Components

// Simple card wrapper
@GenerateCode
struct Card: ComponentBuilder {
    let children: [any Component]
    
    init(@ComponentArrayBuilder content: () -> [any Component]) {
        self.children = content()
    }
    
    func build() -> some Component {
        VStack(alignItems: .stretch, children: children)
            .inset(16)
            .backgroundColor(.systemBackground)
            .cornerRadius(12)
            .borderWidth(1)
            .borderColor(.systemGray4)
    }
}

// Button component
@GenerateCode
struct PrimaryButton: ComponentBuilder {
    var title: String
    var color: UIColor = .systemBlue
    var isEnabled: Bool = true
    var onTap: () -> Void

    func build() -> some Component {
        Text(title, font: .boldSystemFont(ofSize: 16))
            .textColor(isEnabled ? .white : .systemGray)
            .textAlignment(.center)
            .inset(h: 24, v: 12)
            .backgroundColor(isEnabled ? color : .systemGray5)
            .cornerRadius(8)
            .tappableView {
                if isEnabled {
                    onTap()
                }
            }
    }
}

// Section component
@GenerateCode
struct Section: ComponentBuilder {
    let title: String
    let children: [any Component]
    
    init(title: String, @ComponentArrayBuilder content: () -> [any Component]) {
        self.title = title
        self.children = content()
    }
    
    func build() -> some Component {
        VStack(spacing: 6) {
            Text(title, font: .boldSystemFont(ofSize: 14))
                .textColor(.secondaryLabel)
            
            VStack(children: children)
                .backgroundColor(.systemBackground)
                .cornerRadius(12)
        }
    }
}

// UserCard component
@GenerateCode
struct UserCard: ComponentBuilder {
    let name: String
    let email: String
    
    func build() -> some Component {
        HStack(spacing: 12, alignItems: .center) {
            Image(systemName: "person.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
                .tintColor(.systemBlue)
            
            VStack(spacing: 4) {
                Text(name, font: .bodyBold)
                Text(email, font: .body)
                    .textColor(.secondaryLabel)
            }
        }.inset(10)
    }
}

// Avatar component
@GenerateCode
struct Avatar: ComponentBuilder {
    var systemImage: String
    var size: CGFloat
    var backgroundColor: UIColor = .systemBlue

    func build() -> some Component {
        Image(systemName: systemImage, withConfiguration: UIImage.SymbolConfiguration(pointSize: size * 0.5))
            .tintColor(.white)
            .contentMode(.center)
            .size(width: size, height: size)
            .backgroundColor(backgroundColor)
            .cornerRadius(size / 2)
    }
}

// Badge component
@GenerateCode
struct Badge: ComponentBuilder {
    var text: String
    var color: UIColor = .systemBlue

    func build() -> some Component {
        Text(text, font: .boldSystemFont(ofSize: 12))
            .textColor(.white)
            .inset(h: 8, v: 4)
            .backgroundColor(color)
            .cornerRadius(4)
    }
}

// List row component
@GenerateCode
struct ListRow: ComponentBuilder {
    var icon: String
    var title: String
    var subtitle: String
    var iconColor: UIColor = .systemBlue

    func build() -> some Component {
        HStack(spacing: 12, alignItems: .center) {
            Image(systemName: icon)
                .tintColor(iconColor)
                .contentMode(.center)
                .size(width: 24, height: 24)
            
            VStack(spacing: 4) {
                Text(title, font: .bodyBold)
                Text(subtitle, font: .caption)
                    .textColor(.secondaryLabel)
            }
            .flex()
            
            Image(systemName: "chevron.right")
                .tintColor(.tertiaryLabel)
        }
        .inset(16)
    }
}

// FlowGrid - A Flow layout with automatic column sizing
@GenerateCode
struct FlowGrid: Component {
    let columns: Int
    let spacing: CGFloat
    let children: [any Component]
    
    init(columns: Int, spacing: CGFloat = 10, @ComponentArrayBuilder content: () -> [any Component]) {
        self.columns = columns
        self.spacing = spacing
        self.children = content()
    }
    
    func layout(_ constraint: Constraint) -> some RenderNode {
        // Calculate total spacing (N-1 gaps for N columns)
        let totalSpacing = spacing * CGFloat(columns - 1)
        // Calculate width for each item
        let itemWidth = (constraint.maxSize.width - totalSpacing) / CGFloat(columns)
        
        // Wrap all children in Flow layout with calculated width
        return Flow(spacing: spacing) {
            for child in children {
                child.eraseToAnyComponent().size(width: itemWidth)
            }
        }.layout(constraint)
    }
}

// Responsive card that changes layout based on width
@GenerateCode
struct ResponsiveCard: Component {
    let title: String
    let description: String
    let icon: String
    
    func layout(_ constraint: Constraint) -> some RenderNode {
        let width = constraint.maxSize.width
        let isCompact = width < 300
        
        if isCompact {
            // Vertical layout for narrow widths
            return VStack(spacing: 12, alignItems: .center) {
                Image(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
                    .tintColor(.systemBlue)
                
                VStack(spacing: 6, alignItems: .center) {
                    Text(title, font: .bodyBold)
                    Text(description, font: .caption)
                        .textColor(.secondaryLabel)
                        .textAlignment(.center)
                }
            }
            .inset(20)
            .backgroundColor(.systemBackground)
            .cornerRadius(12)
            .borderWidth(1)
            .borderColor(.systemGray4)
            .layout(constraint)
            .eraseToAnyRenderNode()
        } else {
            // Horizontal layout for wider widths
            return HStack(spacing: 16, alignItems: .center) {
                Image(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 50))
                    .tintColor(.systemBlue)
                
                VStack(spacing: 6) {
                    Text(title, font: .title)
                    Text(description, font: .body)
                        .textColor(.secondaryLabel)
                }
                .flex()
            }
            .inset(24)
            .backgroundColor(.systemBackground)
            .cornerRadius(12)
            .borderWidth(1)
            .borderColor(.systemGray4)
            .layout(constraint)
            .eraseToAnyRenderNode()
        }
    }
}

// Custom VStack implementation
@GenerateCode
struct MyVStack: Component {
    var spacing: CGFloat
    var children: [any Component]

    init(spacing: CGFloat = 0, @ComponentArrayBuilder children: () -> [any Component]) {
        self.spacing = spacing
        self.children = children()
    }
    
    func layout(_ constraint: Constraint) -> some RenderNode {
        var childrenRenderNodes: [any RenderNode] = []
        var childrenPositions: [CGPoint] = []
        var currentOffset: CGFloat = 0
        var maxChildWidth: CGFloat = 0
        var maxChildHeight: CGFloat = 0
        
        // Create child constraint: same width, unconstrained height
        let childConstraint = Constraint(maxSize: CGSize(width: constraint.maxSize.width, height: .infinity))
        
        // Layout each child
        for (index, child) in children.enumerated() {
            let childRenderNode = child.layout(childConstraint)
            let childSize = childRenderNode.size
            
            // Position child at x=0, y=currentOffset
            let childPosition = CGPoint(x: 0, y: currentOffset)
            
            // Update offset for next child
            currentOffset += childSize.height
            // Add spacing except after the last child
            if index < children.count - 1 {
                currentOffset += spacing
            }
            
            childrenRenderNodes.append(childRenderNode)
            childrenPositions.append(childPosition)
            
            maxChildWidth = max(maxChildWidth, childSize.width)
            maxChildHeight = max(maxChildHeight, childSize.height)
        }
        
        let totalHeight = currentOffset
        let size = CGSize(width: maxChildWidth, height: totalHeight)
        
        return VerticalRenderNode(
            size: size,
            children: childrenRenderNodes,
            positions: childrenPositions,
            mainAxisMaxValue: maxChildHeight
        )
    }
}

// Diagonal stack - a creative layout example
@GenerateCode
struct DiagonalStack: Component {
    let spacing: CGFloat
    let offset: CGFloat
    let children: [any Component]
    
    init(spacing: CGFloat = 0, offset: CGFloat = 20, @ComponentArrayBuilder children: () -> [any Component]) {
        self.spacing = spacing
        self.offset = offset
        self.children = children()
    }
    
    func layout(_ constraint: Constraint) -> some RenderNode {
        var childrenRenderNodes: [any RenderNode] = []
        var childrenPositions: [CGPoint] = []
        var currentY: CGFloat = 0
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        
        // Create child constraint: unconstrained so children can size themselves
        let childConstraint = Constraint()
        
        for (index, child) in children.enumerated() {
            let childRenderNode = child.layout(childConstraint)
            let childSize = childRenderNode.size
            
            // Position diagonally
            let x = CGFloat(index) * offset
            let y = currentY
            
            let position = CGPoint(x: x, y: y)
            
            childrenRenderNodes.append(childRenderNode)
            childrenPositions.append(position)
            
            currentY += childSize.height + spacing
            maxX = max(maxX, x + childSize.width)
            maxY = max(maxY, y + childSize.height)
        }
        
        let size = CGSize(width: maxX, height: maxY)
        
        // Use SlowRenderNode since items aren't in sorted order
        return SlowRenderNode(
            size: size,
            children: childrenRenderNodes,
            positions: childrenPositions
        )
    }
}

