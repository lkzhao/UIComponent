//
//  SimpleExamplesView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/4/25.
//


class SimpleExamplesView: UIView {
    @Observable
    class IntroViewModel {
        var isSelected: Bool = false
    }

    let viewModel = IntroViewModel()

    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        componentEngine.component = VStack(spacing: 40) {
            Text("Simple Examples", font: .title)
            VStack(spacing: 10) {
                Text("Basic UIComponent hierarchy", font: .subtitle)
                Text("Similar to SwiftUI, UIComponent can be constructed using declarative syntax. Here is a simple example using VStack, Image, and Text", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    VStack {
                        Image(systemName: "square.stack")
                        Text("Hello World")
                    }
                )
            }
            VStack(spacing: 10) {
                Text("Render components", font: .subtitle)
                Text("To render components on screen, assign the component to any UIView's componentEngine.component", font: .body).textColor(.secondaryLabel)
                Code {
                    """
                    view.componentEngine.component = VStack {
                        Image(systemName: "square.stack")
                        Text("Hello World")
                    }
                    """
                }
            }
            VStack(spacing: 10) {
                Text("Passing parameters to component", font: .subtitle)
                Text("You can pass parameters to components like spacing, alignment, font, configurations, etc... Other attributes can be set using modifiers.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    HStack(spacing: 8, alignItems: .center) {
                        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
                        Image(systemName: "square.stack", withConfiguration: config)
                            .tintColor(.label)
                        Text("Hello World", font: .boldSystemFont(ofSize: 16))
                    }
                )
            }
            VStack(spacing: 10) {
                Text("Conditional rendering and tap handling", font: .subtitle)
                Text("You can use standard Swift control flow to conditionally render components. You can also handle tap events using tappableView modifier.", font: .body).textColor(.secondaryLabel)
                #CodeExampleNoInsets(
                    HStack(spacing: 8, alignItems: .center) {
                        if viewModel.isSelected {
                            Image(systemName: "checkmark.square").tintColor(.white)
                        } else {
                            Image(systemName: "square").tintColor(.label)
                        }
                        Text("Tap to select").textColor(viewModel.isSelected ? .white : .label)
                    }.inset(h: 16, v: 10).tappableView {
                        viewModel.isSelected.toggle()
                    }
                    .backgroundColor(viewModel.isSelected ? .systemBlue : .clear)
                )
            }
            VStack(spacing: 10) {
                Text("List Rendering", font: .subtitle)
                Text("You can render lists using standard Swift for loops. Here is an example rendering 200 items inside a scroll view.", font: .body).textColor(.secondaryLabel)
                #CodeExampleNoInsets(
                    VStack {
                        for i in 0...200 {
                            Text("Item \(i)", font: .body).inset(10)
                        }
                    }
                    .scrollView()
                    .size(height: 200)
                )
            }
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}


