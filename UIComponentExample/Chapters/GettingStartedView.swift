//
//  GettingStartedView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/5/25.
//

import UIComponent

class GettingStartedView: UIView {
    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 40) {
            Text("Getting Started", font: .title)
            
            VStack(spacing: 10) {
                Text("Welcome to UIComponent example!", font: .subtitle)
                Text("This example app demonstrates how to use UIComponent, a declarative UI framework for building native iOS apps with Swift.", font: .body).textColor(.secondaryLabel)
            }
            
            VStack(spacing: 10) {
                Text("How to use this app", font: .subtitle)
                VStack(spacing: 10) {
                    Text("• Use the sidebar on the left to navigate between different chapters", font: .body).textColor(.secondaryLabel)
                    Text("• Each chapter demonstrates different UIComponent features and concepts", font: .body).textColor(.secondaryLabel)
                    Text("• Code examples are live and interactive. You can also copy the code snippets to try them out in your projects.", font: .body).textColor(.secondaryLabel)
                }
            }
            
            VStack(spacing: 15) {
                Text("Exploring the code", font: .subtitle)
                VStack(spacing: 10) {
                    VStack(spacing: 4) {
                        Text("1. Start with HomeView.swift", font: .bodyBold)
                        Text("This is the main entry point that sets up the sidebar navigation and chapter content", font: .body).textColor(.secondaryLabel)
                    }
                    VStack(spacing: 4) {
                        Text("2. Check out SimpleExamplesView.swift", font: .bodyBold)
                        Text("This is a great starting point to see how components are composed using VStack, HStack, Text, and Image", font: .body).textColor(.secondaryLabel)
                    }
                    VStack(spacing: 4) {
                        Text("3. Browse the Chapters folder", font: .bodyBold)
                        Text("Each chapter is a separate UIView class demonstrating specific features", font: .body).textColor(.secondaryLabel)
                    }
                }
            }
            
            VStack(spacing: 10) {
                Text("Ready to Start?", font: .subtitle)
                Text("Navigate to \"Simple Examples\" in the sidebar to see UIComponent in action!", font: .body).textColor(.secondaryLabel)
            }
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}
