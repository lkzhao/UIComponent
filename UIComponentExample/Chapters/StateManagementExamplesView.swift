//  Created by Luke Zhao on 11/6/25.

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIComponent

class StateManagementExamplesView: UIView {
    @Observable
    class ViewModel {
        var observableCount: Int = 0
        var selectedItems: Set<UUID> = []
        var itemStates: [UUID: ItemState] = [:]
        var items: [ItemModel] = [
            ItemModel(id: UUID(), title: "Item 1"),
            ItemModel(id: UUID(), title: "Item 2"),
            ItemModel(id: UUID(), title: "Item 3")
        ]
    }
    
    let viewModel = ViewModel()
    
    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        
        componentEngine.component = VStack(spacing: 40) {
            Text("State Management", font: .title)
            
            VStack(spacing: 10) {
                Text("What is state management?", font: .subtitle)
                Text("State management in UIComponent refers to how you handle dynamic data that changes over time and triggers UI updates. UIComponent supports multiple patterns for managing state.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 8) {
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.clockwise")
                            .tintColor(.systemBlue)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Manual reloading with reloadComponent()", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "eye")
                            .tintColor(.systemGreen)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Observable pattern (iOS 26+)", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "list.bullet")
                            .tintColor(.systemOrange)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("List item state management", font: .body)
                    }
                }.inset(h: 16, v: 10).backgroundColor(.systemGray6).cornerRadius(12)
            }
            
            // MARK: - Manual State Management
            
            VStack(spacing: 10) {
                Text("Manual state management with reloadComponent()", font: .subtitle)
                Text("The traditional approach is to manually call reloadComponent() whenever state changes. This gives you explicit control over when the UI updates.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6, alignItems: .start) {
                        Text("Basic pattern", font: .bodyBold)
                        Text("Use property observers (didSet) to trigger reloadComponent() when state changes.", font: .body).textColor(.secondaryLabel)
                        
                        ViewComponent<ManualCounterExample>()
                            .size(width: 300, height: 180)

                        Code(ManualCounterExample.codeRepresentation)
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6, alignItems: .start) {
                        Text("Key points", font: .bodyBold)
                        
                        VStack(spacing: 8, alignItems: .start) {
                            VStack(spacing: 4, alignItems: .start) {
                                Text("Guard against unnecessary updates", font: .bodyBold)
                                Text("Always check if the value actually changed using 'guard count != oldValue else { return }' to avoid unnecessary reloads.", font: .body).textColor(.secondaryLabel)
                            }
                            
                            VStack(spacing: 4, alignItems: .start) {
                                Text("Initial setup in init", font: .bodyBold)
                                Text("Call reloadComponent() in your initializer to set up the initial component tree.", font: .body).textColor(.secondaryLabel)
                            }
                            
                            VStack(spacing: 4, alignItems: .start) {
                                Text("Use [unowned self] in closures", font: .bodyBold)
                                Text("Since the view owns the component tree, use [unowned self] in tap handlers to avoid retain cycles. The component tree is released when reloadComponent() is called.", font: .body).textColor(.secondaryLabel)
                            }
                        }
                        .inset(12)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(8)
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6, alignItems: .start) {
                        Text("Observing external view model with Combine", font: .bodyBold)
                        Text("You can use Combine to observe an external view model or data source and trigger reloadComponent() when it changes. This is useful when there are multiple states or sharing state across multiple views.", font: .body).textColor(.secondaryLabel)

                        Code {
                            """
                            import Combine
                            
                            class AppViewModel: ObservableObject {
                                @Published var count: Int = 0
                                @Published var message: String = "Hello"
                            }
                            
                            class MyView: UIView {
                                let viewModel: AppViewModel
                                var cancellables = Set<AnyCancellable>()
                                
                                init(viewModel: AppViewModel) {
                                    self.viewModel = viewModel
                                    super.init(frame: .zero)
                                    
                                    // Observe view model changes
                                    viewModel.objectWillChange.sink { [weak self] _ in
                                        self?.reloadComponent()
                                    }
                                    .store(in: &cancellables)
                                    
                                    reloadComponent()
                                }
                                
                                required init?(coder: NSCoder) {
                                    fatalError("init(coder:) has not been implemented")
                                }
                                
                                func reloadComponent() {
                                    componentEngine.component = VStack {
                                        Text("Count: \\(viewModel.count)")
                                        Text("Message: \\(viewModel.message)")
                                        
                                        Text("Increase").tappableView { [unowned self] in
                                            self.viewModel.count += 1
                                        }
                                    }
                                }
                            }
                            """
                        }
                    }
                }
            }
            
            // MARK: - Observable Pattern (iOS 26+)
            
            VStack(spacing: 10) {
                Text("Observable pattern with updateProperties (iOS 26+)", font: .subtitle).id("observable-pattern")
                Text("On iOS 26 and later, use the @Observable macro with updateProperties() for automatic UI updates. This modern approach eliminates manual reloadComponent() calls.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 15) {
                    VStack(spacing: 6, alignItems: .start) {
                        Text("How it works", font: .bodyBold)
                        Text("The @Observable macro automatically tracks property access. When you override updateProperties() and access @Observable properties, UIKit automatically calls setNeedsUpdateProperties() when those properties change.", font: .body).textColor(.secondaryLabel)

                        VStack(spacing: 8, alignItems: .start) {
                            VStack(spacing: 4, alignItems: .start) {
                                Text("Automatic tracking", font: .bodyBold)
                                Text("Any @Observable property accessed in updateProperties() is automatically tracked. When it changes, updateProperties() is called again.", font: .body).textColor(.secondaryLabel)
                            }
                            
                            VStack(spacing: 4, alignItems: .start) {
                                Text("No manual calls needed", font: .bodyBold)
                                Text("You don't need didSet observers or manual setNeedsUpdateProperties() calls. The system handles it automatically.", font: .body).textColor(.secondaryLabel)
                            }
                            
                            VStack(spacing: 4, alignItems: .start) {
                                Text("Efficient updates", font: .bodyBold)
                                Text("Only properties actually accessed during rendering are tracked, minimizing unnecessary updates.", font: .body).textColor(.secondaryLabel)
                            }
                        }
                        .inset(12)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(8)
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6, alignItems: .start) {
                        Text("Basic Observable example", font: .bodyBold)
                        Text("This example demonstrates the Observable pattern. The count is tracked automatically and UI updates when it changes.", font: .body).textColor(.secondaryLabel)
                        
                        ViewComponent<AutoCounterExample>()
                            .size(width: 300, height: 180)

                        Code(AutoCounterExample.codeRepresentation)
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6, alignItems: .start) {
                        Text("Why does Observable work?", font: .bodyBold)
                        Text("Understanding the mechanism behind Observable tracking:", font: .body).textColor(.secondaryLabel)
                        
                        VStack(spacing: 8, alignItems: .start) {
                            VStack(spacing: 4, alignItems: .start) {
                                Text("1. Property access tracking", font: .bodyBold)
                                Text("When updateProperties() runs, @Observable tracks which properties are accessed (e.g., viewModel.count).", font: .body).textColor(.secondaryLabel)
                            }
                            
                            VStack(spacing: 4, alignItems: .start) {
                                Text("2. Change notification", font: .bodyBold)
                                Text("When a tracked property changes, @Observable notifies all observers.", font: .body).textColor(.secondaryLabel)
                            }
                            
                            VStack(spacing: 4, alignItems: .start) {
                                Text("3. UIView integration", font: .bodyBold)
                                Text("UIView's updateProperties() implementation automatically observes @Observable objects, calling setNeedsUpdateProperties() when they change.", font: .body).textColor(.secondaryLabel)
                            }
                            
                            VStack(spacing: 4, alignItems: .start) {
                                Text("4. Efficient batching", font: .bodyBold)
                                Text("Multiple property changes are batched together, triggering only one updateProperties() call.", font: .body).textColor(.secondaryLabel)
                            }
                        }
                        .inset(12)
                        .backgroundColor(.systemBlue.withAlphaComponent(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            
            // MARK: - List Item State Management
            
            VStack(spacing: 10) {
                Text("Managing state for list items", font: .subtitle)
                Text("When building lists with interactive items, store each item's state in the parent view model using a dictionary or array. Pass the state down to each item component.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 15) {
                    Code {
                        """
                        @Observable
                        class ViewModel {
                            // Store state for each item by ID
                            var itemStates: [UUID: ItemState] = [:]
                            var items: [ItemModel] = [...]
                        }
                        
                        // In updateProperties():
                        for item in viewModel.items {
                            let state = viewModel.itemStates[item.id] ?? ItemState()
                            ItemComponent(
                                item: item,
                                state: state,
                                onStateChange: { newState in
                                    viewModel.itemStates[item.id] = newState
                                }
                            )
                        }
                        """
                    }

                    Separator()
                    
                    VStack(spacing: 6, alignItems: .start) {
                        Text("Interactive list example", font: .bodyBold)
                        Text("Toggle selection state for each item. State is preserved even when scrolling.", font: .body).textColor(.secondaryLabel)
                        
                        #CodeExampleNoInsets(
                            VStack {
                                Join {
                                    for item in viewModel.items {
                                        let isSelected = viewModel.selectedItems.contains(item.id)
                                        
                                        HStack(spacing: 12, alignItems: .center) {
                                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                                .tintColor(isSelected ? .systemBlue : .secondaryLabel)
                                                .contentMode(.center)
                                                .size(width: 24, height: 24)
                                            
                                            Text(item.title, font: .body)
                                                .flex()
                                            
                                            if isSelected {
                                                Image(systemName: "checkmark")
                                                    .tintColor(.systemBlue)
                                            }
                                        }
                                        .inset(h: 16, v: 12)
                                        .backgroundColor(isSelected ? .systemBlue.withAlphaComponent(0.1) : .clear)
                                        .tappableView {
                                            if isSelected {
                                                viewModel.selectedItems.remove(item.id)
                                            } else {
                                                viewModel.selectedItems.insert(item.id)
                                            }
                                        }
                                    }
                                } separator: {
                                    Separator().inset(h: 16)
                                }
                            }
                        )
                    }
                    
                    Separator()
                    
                    VStack(spacing: 6, alignItems: .start) {
                        Text("Complex item state with dictionary", font: .bodyBold)
                        Text("For items with more complex state (expanded/collapsed, editing mode, etc.), use a dictionary to store state objects.", font: .body).textColor(.secondaryLabel)
                        
                        ViewComponent<ComplexListExample>()
                            .size(width: 320, height: 400)

                        Code(ComplexListExample.codeRepresentation)
                    }
                }
            }

            // MARK: - Comparison
            
            VStack(spacing: 10) {
                Text("Manual vs Observable: When to use each", font: .subtitle)
                
                VStack(spacing: 12) {
                    VStack(spacing: 8, alignItems: .start) {
                        Text("✅ Use Manual reloadComponent() when:", font: .bodyBold).textColor(.systemGreen)
                        VStack(spacing: 4, alignItems: .start) {
                            Text("• You need to support iOS versions before iOS 26", font: .body)
                            Text("• You want explicit control over when updates happen", font: .body)
                            Text("• You're integrating with existing non-Observable code", font: .body)
                        }
                    }
                    .inset(16)
                    .backgroundColor(.systemGreen.withAlphaComponent(0.1))
                    .cornerRadius(12)
                    
                    VStack(spacing: 8, alignItems: .start) {
                        Text("✅ Use Observable with updateProperties() when:", font: .bodyBold).textColor(.systemBlue)
                        VStack(spacing: 4, alignItems: .start) {
                            Text("• You're targeting iOS 26+", font: .body)
                            Text("• You want automatic UI updates without boilerplate", font: .body)
                            Text("• Your view model has many state properties", font: .body)
                            Text("• You want cleaner, more declarative code", font: .body)
                        }
                    }
                    .inset(16)
                    .backgroundColor(.systemBlue.withAlphaComponent(0.1))
                    .cornerRadius(12)
                }
            }
            
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}
// MARK: - Manual State Management Examples

@GenerateCode
class ManualCounterExample: UIView {
    var count: Int = 0 {
        didSet {
            guard count != oldValue else { return }
            reloadComponent()
        }
    }
    
    init() {
        super.init(frame: .zero)
        reloadComponent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadComponent() {
        componentEngine.component = VStack(spacing: 16, justifyContent: .spaceEvenly, alignItems: .center) {
            Text("Manual Counter", font: .subtitle)

            Text("Count: \(count)", font: .title)
                .textColor(.systemBlue)
            
            HStack(spacing: 12) {
                Text("Decrease", font: .bodyBold)
                    .inset(h: 20, v: 12)
                    .backgroundColor(.systemRed)
                    .textColor(.white)
                    .cornerRadius(8)
                    .tappableView { [unowned self] in
                        self.count -= 1
                    }
                
                Text("Increase", font: .bodyBold)
                    .inset(h: 20, v: 12)
                    .backgroundColor(.systemGreen)
                    .textColor(.white)
                    .cornerRadius(8)
                    .tappableView { [unowned self] in
                        self.count += 1
                    }
            }
        }
        .inset(16)
        .backgroundColor(.systemGray6)
        .cornerRadius(12)
        .fill()
    }
}

@GenerateCode
class AutoCounterExample: UIView {
    @Observable
    class ViewModel {
        var count: Int = 0
    }

    let viewModel = ViewModel()

    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel

        componentEngine.component = VStack(spacing: 16, justifyContent: .spaceEvenly, alignItems: .center) {
            Text("Auto Counter", font: .subtitle)

            Text("Count: \(viewModel.count)", font: .title)
                .textColor(.systemBlue)

            HStack(spacing: 12) {
                Text("Decrease", font: .bodyBold)
                    .inset(h: 20, v: 12)
                    .backgroundColor(.systemRed)
                    .textColor(.white)
                    .cornerRadius(8)
                    .tappableView {
                        viewModel.count -= 1
                    }

                Text("Increase", font: .bodyBold)
                    .inset(h: 20, v: 12)
                    .backgroundColor(.systemGreen)
                    .textColor(.white)
                    .cornerRadius(8)
                    .tappableView {
                        viewModel.count += 1
                    }
            }
        }
        .inset(16)
        .backgroundColor(.systemGray6)
        .cornerRadius(12)
        .fill()
    }
}

// MARK: - List Item State Examples

struct ItemModel: Identifiable {
    let id: UUID
    let title: String
}

struct ItemState {
    var isExpanded: Bool = false
    var note: String = ""
    var rating: Int = 0
}

@GenerateCode
class ComplexListExample: UIView {
    @Observable
    class ViewModel {
        var items: [ItemModel] = [
            ItemModel(id: UUID(), title: "Learn UIComponent"),
            ItemModel(id: UUID(), title: "Build amazing apps"),
            ItemModel(id: UUID(), title: "Ship to App Store")
        ]
        var itemStates: [UUID: ItemState] = [:]
    }
    
    let viewModel = ViewModel()
    
    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        
        componentEngine.component = VStack(alignItems: .stretch) {
            // Header
            HStack(spacing: 10, alignItems: .center) {
                Text("Todo List", font: .bodyBold)
                Spacer()
                Text("\(viewModel.items.count) items", font: .caption)
                    .textColor(.secondaryLabel)
            }
            .inset(16)
            .backgroundColor(.systemGray6)
            
            Separator()
            
            // List items
            VStack(alignItems: .stretch) {
                Join {
                    for item in viewModel.items {
                        let state = viewModel.itemStates[item.id, default: ItemState()]
                        
                        VStack(alignItems: .stretch) {
                            // Item header (always visible)
                            HStack(spacing: 12, alignItems: .center) {
                                Image(systemName: state.isExpanded ? "chevron.down" : "chevron.right")
                                    .tintColor(.secondaryLabel)
                                    .contentMode(.center)
                                    .size(width: 20, height: 20)
                                
                                Text(item.title, font: .body)

                                Spacer()

                                // Star rating
                                HStack(spacing: 4) {
                                    for i in 1...5 {
                                        Image(systemName: i <= state.rating ? "star.fill" : "star")
                                            .tintColor(.systemYellow)
                                            .contentMode(.center)
                                            .size(width: 16, height: 16)
                                            .tappableView {
                                                var newState = state
                                                newState.rating = i
                                                viewModel.itemStates[item.id] = newState
                                            }
                                    }
                                }
                            }
                            .inset(12)
                            .tappableView {
                                var newState = state
                                newState.isExpanded.toggle()
                                viewModel.itemStates[item.id] = newState
                            }

                            // Expanded content
                            if state.isExpanded {
                                VStack(spacing: 8, alignItems: .start) {
                                    Text("Notes:", font: .caption).textColor(.secondaryLabel)
                                    Text(state.note.isEmpty ? "No notes yet. Tap to add..." : state.note, font: .body)
                                        .textColor(state.note.isEmpty ? .tertiaryLabel : .label)
                                        .tappableView {
                                            var newState = state
                                            newState.note = state.note.isEmpty ? "Sample note for \(item.title)" : ""
                                            viewModel.itemStates[item.id] = newState
                                        }
                                }
                                .inset(h: 16, v: 12)
                                .backgroundColor(.systemGray6.withAlphaComponent(0.5))
                            }
                        }
                    }
                } separator: {
                    Separator().inset(h: 16)
                }
            }
            .scrollView()
            .flex()
        }
        .view()
        .backgroundColor(.systemBackground)
        .cornerRadius(12)
        .borderWidth(1)
        .borderColor(.systemGray4)
        .clipsToBounds(true)
    }
}

#endif
