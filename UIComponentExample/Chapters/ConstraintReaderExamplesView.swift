//
//  ConstraintReaderExamplesView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/5/25.
//

import UIComponent

class ConstraintReaderExamplesView: UIView {
    @Observable
    class ViewModel {
        var widthPercentage: Double = 1.0
    }
    
    let viewModel = ViewModel()
    
    override func updateProperties() {
        super.updateProperties()
        let viewModel = viewModel
        componentEngine.component = VStack(spacing: 40) {
            Text("ConstraintReader Examples", font: .title)
            
            VStack(spacing: 10) {
                Text("Overview", font: .subtitle)
                Text("Before exploring ConstraintReader, make sure you understand the Sizing & Constraints chapter.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 8) {
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .tintColor(.systemBlue)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Read parent constraints", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "rectangle.expand.vertical")
                            .tintColor(.systemGreen)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Solve infinite layout issues", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "square.grid.3x3")
                            .tintColor(.systemOrange)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("Calculate dynamic layouts", font: .body)
                    }
                }.inset(16).backgroundColor(.systemGray6).cornerRadius(12)
            }
            
            // MARK: - The Problem: Infinite Constraints
            
            VStack(spacing: 10) {
                Text("The Problem: Infinite Constraints", font: .subtitle)
                Text("Certain layouts like HStack and VStack make their main axis unbounded (infinite maxSize). This breaks percentage sizing and .fill strategies.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("HStack makes maxSize.width infinite, so percentage sizing fails.", font: .caption).textColor(.secondaryLabel)
                    Text("Result: Component gets zero or unexpected width", font: .caption).textColor(.systemRed)
                    #CodeExample(
                        HStack {
                            // ❌ Won't work - trying to use percentage sizing on infinite width
                            Space(height: 30)
                                .backgroundColor(.systemBlue)
                                .size(width: .percentage(0.5))
                            
                            Text("← Left item has unexpected width")
                                .size(height: 30)
                                .backgroundColor(.systemGray5)
                        }
                    )
                }

                VStack(spacing: 10) {
                    Text(".fill doesn't work in HStack", font: .bodyBold)

                    #CodeExample(
                        HStack(spacing: 10) {
                            // ❌ Fails - trying to fill infinite width
                            Space(height: 30)
                                .backgroundColor(.systemGreen)
                                .size(width: .fill)

                            Text("Fixed")
                                .size(height: 30)
                                .backgroundColor(.systemOrange)
                        }
                    )
                }
            }
            
            // MARK: - The Solution: ConstraintReader
            
            VStack(spacing: 10) {
                Text("✅ The Solution: ConstraintReader", font: .subtitle)
                Text("ConstraintReader captures the parent constraint before it becomes infinite, allowing you to pass it down to child components.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Basic usage", font: .caption)
                    Text("✅ Now it works!", font: .caption).textColor(.systemGreen)
                    #CodeExample(
                        ConstraintReader { constraint in
                            HStack {
                                Space(height: 30)
                                    .backgroundColor(.systemBlue)
                                    .size(width: .percentage(0.5))
                                    .constraint(constraint)
                                
                                Text("← Left item is 50% width")
                                    .size(height: 30)
                                    .backgroundColor(.systemGray5)
                            }
                        }
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("✅ .fill strategy with ConstraintReader", font: .subtitle)
                VStack(spacing: 10) {
                    Text("Full width items in HStack", font: .caption)
                    #CodeExample(
                        ConstraintReader { constraint in
                            HStack(spacing: 10) {
                                Space(height: 30)
                                    .backgroundColor(.systemGreen)
                                    .size(width: .fill)
                                    .constraint(constraint)
                                
                                Text("Fixed")
                                    .size(height: 30)
                                    .backgroundColor(.systemOrange)
                            }
                        }.scrollView()
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("✅ Multiple percentage items", font: .subtitle)
                Text("Each item reads parent constraint to calculate its percentage width.", font: .body).textColor(.secondaryLabel)

                #CodeExample(
                    ConstraintReader { constraint in
                        HStack {
                            Space(height: 60)
                                .backgroundColor(.systemPurple)
                                .size(width: .percentage(0.5))
                                .constraint(constraint)
                                .overlay {
                                    Text("50%").textAlignment(.center).textColor(.white)
                                }

                            Space(height: 60)
                                .backgroundColor(.systemIndigo)
                                .size(width: .percentage(0.3))
                                .constraint(constraint)
                                .overlay {
                                    Text("30%").textAlignment(.center).textColor(.white)
                                }

                            Space(height: 60)
                                .backgroundColor(.systemTeal)
                                .size(width: .percentage(0.2))
                                .constraint(constraint)
                                .overlay {
                                    Text("20%").textAlignment(.center).textColor(.white)
                                }
                        }
                    }
                )
            }
            
            // MARK: - Dynamic Layout Properties
            
            VStack(spacing: 10) {
                Text("Dynamic Layout Properties", font: .subtitle)
                Text("ConstraintReader can calculate layout properties based on available space.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Adjust the slider to limit the width and see how the layout adapts.", font: .caption).textColor(.secondaryLabel)
                    
                    // Slider control
                    HStack(spacing: 12, alignItems: .center) {
                        Text("Width:", font: .body)
                        
                        ViewComponent<Slider>()
                            .value(viewModel.widthPercentage)
                            .onValueChanged { [weak self] newValue in
                                self?.viewModel.widthPercentage = newValue
                            }
                            .update { slider in
                                slider.slider.minimumValue = 0.1
                                slider.slider.maximumValue = 1.0
                            }
                            .size(width: 200, height: 30)
                            .flex()
                        
                        Text("\(Int(viewModel.widthPercentage * 100))%", font: .bodyBold)
                            .size(width: 50)
                            .textAlignment(.right)
                    }
                    .inset(h: 16, v: 12)
                    .backgroundColor(.systemGray6)
                    .cornerRadius(12)
                    
                    Text("Responsive font size", font: .caption)
                    #CodeExample(
                        ConstraintReader { constraint in
                            let width = constraint.maxSize.width
                            let fontSize: CGFloat = if width > 300 { 24 }
                                else if width > 200 { 18 }
                                else { 14 }

                            return VStack(spacing: 8) {
                                Text("Width: \(Int(width))pt", font: .caption)
                                    .textColor(.secondaryLabel)
                                Text("Responsive Text", font: .systemFont(ofSize: fontSize, weight: .bold))
                                Text("Font size: \(Int(fontSize))pt", font: .caption)
                                    .textColor(.secondaryLabel)
                            }
                        }.size(width: .percentage(viewModel.widthPercentage))
                    )
                    
                    Text("Horizontal paginated view", font: .caption)
                    Text("Each page fills the full width of the container. Perfect for onboarding screens or image galleries.", font: .caption).textColor(.secondaryLabel)
                    #CodeExampleNoInsets(
                        ConstraintReader { constraint in
                            HStack {
                                // Page 1
                                VStack(spacing: 12, justifyContent: .center, alignItems: .center) {
                                    Image(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
                                        .tintColor(.systemYellow)
                                    Text("Page 1", font: .title)
                                    Text("Swipe to continue →", font: .body)
                                        .textColor(.secondaryLabel)
                                }
                                .fill()
                                .constraint(constraint)
                                .backgroundColor(.systemYellow.withAlphaComponent(0.1))
                                
                                // Page 2
                                VStack(spacing: 12, justifyContent: .center, alignItems: .center) {
                                    Image(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
                                        .tintColor(.systemPink)
                                    Text("Page 2", font: .title)
                                    Text("Swipe to continue →", font: .body)
                                        .textColor(.secondaryLabel)
                                }
                                .fill()
                                .constraint(constraint)
                                .backgroundColor(.systemPink.withAlphaComponent(0.1))
                                
                                // Page 3
                                VStack(spacing: 12, justifyContent: .center, alignItems: .center) {
                                    Image(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
                                        .tintColor(.systemGreen)
                                    Text("Page 3", font: .title)
                                    Text("All done!", font: .body)
                                        .textColor(.secondaryLabel)
                                }
                                .fill()
                                .constraint(constraint)
                                .backgroundColor(.systemGreen.withAlphaComponent(0.1))
                            }
                            .scrollView()
                            .isPagingEnabled(true)
                        }.size(width: .percentage(viewModel.widthPercentage), height: 200)
                    )
                }
            }
            
            // MARK: - Custom Constraint Calculations
            
            VStack(spacing: 10) {
                Text("Custom Constraint Calculations", font: .subtitle)
                Text("Access constraint properties to make advanced sizing decisions.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("Square based on available width", font: .caption)
                    #CodeExampleNoInsets(
                        ConstraintReader { constraint in
                            let size = min(constraint.maxSize.width - 20, 200)
                            return Space(width: size, height: size)
                                .backgroundColor(.systemPurple)
                                .cornerRadius(12)
                                .overlay {
                                    VStack(spacing: 4) {
                                        Text("\(Int(size))×\(Int(size))", font: .bodyBold)
                                            .textColor(.white)
                                        Text("Square", font: .caption)
                                            .textColor(.white.withAlphaComponent(0.8))
                                    }.inset(12)
                                }
                        }
                    )
                    
                    Text("Aspect ratio calculation", font: .caption)
                    Text("Maintain 16:9 aspect ratio within available space.", font: .caption).textColor(.secondaryLabel)
                    #CodeExampleNoInsets(
                        ConstraintReader { constraint in
                            let maxWidth = constraint.maxSize.width - 20
                            let maxHeight = constraint.maxSize.height
                            
                            // Calculate 16:9 dimensions that fit
                            let widthBasedHeight = maxWidth * (9.0 / 16.0)
                            let heightBasedWidth = maxHeight * (16.0 / 9.0)
                            
                            let size: CGSize
                            if widthBasedHeight <= maxHeight {
                                size = CGSize(width: maxWidth, height: widthBasedHeight)
                            } else {
                                size = CGSize(width: heightBasedWidth, height: maxHeight)
                            }
                            
                            return Space(width: size.width, height: size.height)
                                .backgroundColor(.systemIndigo)
                                .overlay {
                                    VStack(spacing: 4) {
                                        Text("16:9 Video", font: .bodyBold)
                                            .textColor(.white)
                                        Text("\(Int(size.width))×\(Int(size.height))", font: .caption)
                                            .textColor(.white.withAlphaComponent(0.8))
                                    }.inset(12)
                                }
                        }.size(height: 200)
                    )
                }
            }
            
            // MARK: - Practical Examples
            
            VStack(spacing: 10) {
                Text("Practical Examples", font: .subtitle)
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text("Horizontal scrolling cards", font: .caption)
                        Text("Each card takes 80% of screen width.", font: .caption).textColor(.secondaryLabel)
                        #CodeExampleNoInsets(
                            ConstraintReader { constraint in
                                HStack(spacing: 15) {
                                    for i in 1...5 {
                                        VStack(spacing: 12) {
                                            Text("Card \(i)", font: .bodyBold)
                                            Text("This card is 80% of the container width")
                                                .textColor(.secondaryLabel)
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Text("Action →")
                                                    .textColor(.systemBlue)
                                            }
                                        }
                                        .inset(16)
                                        .backgroundColor(.systemBackground)
                                        .cornerRadius(12)
                                        .size(width: .percentage(0.8), height: .fill)
                                        .constraint(constraint)
                                    }
                                }
                                .inset(h: 16, v: 10)
                                .scrollView()
                                .size(height: 150)
                            }
                        )
                    }
                    
                    VStack(spacing: 10) {
                        Text("Split view layout", font: .caption)
                        Text("Left sidebar 30%, right content 70%.", font: .caption).textColor(.secondaryLabel)
                        #CodeExampleNoInsets(
                            ConstraintReader { constraint in
                                HStack {
                                    VStack(spacing: 8) {
                                        Text("Sidebar", font: .bodyBold)
                                        Text("30% width", font: .caption)
                                            .textColor(.secondaryLabel)
                                    }
                                    .inset(16)
                                    .backgroundColor(.systemBlue.withAlphaComponent(0.1))
                                    .size(width: .percentage(0.3), height: .fill)
                                    .constraint(constraint)
                                    
                                    VStack(spacing: 8) {
                                        Text("Content", font: .bodyBold)
                                        Text("70% width", font: .caption)
                                            .textColor(.secondaryLabel)
                                    }
                                    .inset(16)
                                    .backgroundColor(.systemGreen.withAlphaComponent(0.1))
                                    .size(width: .percentage(0.7), height: .fill)
                                    .constraint(constraint)
                                }
                            }.size(height: 120)
                        )
                    }
                    
                    VStack(spacing: 10) {
                        Text("Progress bar segments", font: .caption)
                        Text("Multiple progress segments in HStack.", font: .caption).textColor(.secondaryLabel)
                        #CodeExample(
                            ConstraintReader { constraint in
                                VStack(spacing: 8) {
                                    Text("Progress: 60%", font: .caption)
                                        .textColor(.secondaryLabel)
                                    
                                    HStack(spacing: 2) {
                                        Space(height: 8)
                                            .backgroundColor(.systemGreen)
                                            .cornerRadius(4)
                                            .size(width: .percentage(0.6))
                                            .constraint(constraint)
                                        
                                        Space(height: 8)
                                            .backgroundColor(.systemGray5)
                                            .cornerRadius(4)
                                            .size(width: .percentage(0.4))
                                            .constraint(constraint)
                                    }
                                }
                            }
                        )
                    }
                    
                    VStack(spacing: 10) {
                        Text("Column grid with spacing", font: .caption)
                        Text("Three equal columns accounting for spacing.", font: .caption).textColor(.secondaryLabel)
                        #CodeExample(
                            ConstraintReader { constraint in
                                let spacing: CGFloat = 12
                                let totalSpacing = spacing * 2 // 2 gaps for 3 columns
                                let columnWidth = (constraint.maxSize.width - totalSpacing - 20) / 3

                                return VStack(spacing: 12) {
                                    HStack(spacing: spacing) {
                                        for i in 1...3 {
                                            VStack(spacing: 8) {
                                                Image(systemName: "square.fill")
                                                    .tintColor(.systemBlue)
                                                Text("Col \(i)", font: .caption)
                                            }
                                            .inset(12)
                                            .backgroundColor(.systemGray5)
                                            .cornerRadius(8)
                                            .size(width: columnWidth)
                                        }
                                    }

                                    HStack(spacing: spacing) {
                                        for i in 4...6 {
                                            VStack(spacing: 8) {
                                                Image(systemName: "square.fill")
                                                    .tintColor(.systemGreen)
                                                Text("Col \(i)", font: .caption)
                                            }
                                            .inset(12)
                                            .backgroundColor(.systemGray5)
                                            .cornerRadius(8)
                                            .size(width: columnWidth)
                                        }
                                    }
                                }
                            }
                        )
                    }
                }
            }
            
            // MARK: - Memory Management
            
            VStack(spacing: 10) {
                Text("⚠️ Memory Management Warning", font: .subtitle)
                Text("ConstraintReader captures an escaping closure that's called later at layout time. Be careful not to create retain cycles when capturing self.", font: .body).textColor(.secondaryLabel)
                
                VStack(spacing: 10) {
                    Text("❌ Bad: Strong reference cycle", font: .caption)
                    Text("Capturing self strongly creates a retain cycle because the view holds the component, and the component's closure holds the view.", font: .caption).textColor(.secondaryLabel)
                    Code {
                        """
                        ConstraintReader { constraint in
                            // ❌ BAD: Strong capture of self
                            let data = self.loadData()
                            return Text(data)
                        }
                        """
                    }
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("1.", font: .body).textColor(.systemRed)
                            Text("View holds the component hierarchy", font: .body)
                        }
                        HStack(spacing: 8) {
                            Text("2.", font: .body).textColor(.systemRed)
                            Text("Component contains ConstraintReader", font: .body)
                        }
                        HStack(spacing: 8) {
                            Text("3.", font: .body).textColor(.systemRed)
                            Text("ConstraintReader's closure strongly captures self", font: .body)
                        }
                        HStack(spacing: 8) {
                            Text("→", font: .body).textColor(.systemRed)
                            Text("Retain cycle! View never deallocates", font: .bodyBold).textColor(.systemRed)
                        }
                    }.inset(16).backgroundColor(.systemRed.withAlphaComponent(0.1)).cornerRadius(12)
                    
                    Text("✅ Good: Weak capture", font: .caption)
                    Text("Use [weak self] to break the retain cycle.", font: .caption).textColor(.secondaryLabel)
                    Code {
                        """
                        ConstraintReader { [weak self] constraint in
                            // ✅ GOOD: Weak capture
                            guard let self else {
                                return Space()
                            }
                            let data = self.loadData()
                            return Text(data)
                        }
                        """
                    }
                    
                    Text("✅ Alternative: Use local variables", font: .caption)
                    Text("Capture only what you need by copying to local variables.", font: .caption).textColor(.secondaryLabel)
                    Code {
                        """
                        let viewModel = self.viewModel // Capture before closure
                        
                        ConstraintReader { constraint in
                            // ✅ GOOD: Only captures viewModel, not self
                            return Text(viewModel.title)
                        }
                        """
                    }
                    
                    Text("✅ Best: Capture only values", font: .caption)
                    Text("When possible, extract values before creating the closure.", font: .caption).textColor(.secondaryLabel)
                    Code {
                        """
                        let percentage = self.widthPercentage // Copy value
                        
                        ConstraintReader { constraint in
                            // ✅ BEST: Only captures a value type
                            let width = constraint.maxSize.width * percentage
                            return Space(width: width, height: 50)
                        }
                        """
                    }
                }
                
                VStack(spacing: 10) {
                    Text("Real example from this chapter", font: .caption)
                    Text("Notice how we used a local variable to avoid capturing self.", font: .caption).textColor(.secondaryLabel)
                    Code {
                        """
                        override func updateProperties() {
                            super.updateProperties()
                            let viewModel = viewModel // ✅ Local variable
                            
                            componentEngine.component = VStack {
                                ConstraintReader { constraint in
                                    // Safe: captures local viewModel, not self
                                    let width = constraint.maxSize.width * viewModel.widthPercentage
                                    return Text("Width: \\(width)")
                                }
                            }
                        }
                        """
                    }
                }
                
                VStack(spacing: 10) {
                    Text("Key Rules", font: .subtitle)
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Text("1.", font: .bodyBold).textColor(.systemBlue)
                            VStack(spacing: 4) {
                                Text("ConstraintReader's closure is escaping", font: .body)
                                Text("It's stored and called later during layout", font: .caption).textColor(.secondaryLabel)
                            }
                        }
                        
                        HStack(spacing: 10) {
                            Text("2.", font: .bodyBold).textColor(.systemBlue)
                            VStack(spacing: 4) {
                                Text("Use [weak self] when accessing self", font: .body)
                                Text("Prevents retain cycles between view and component", font: .caption).textColor(.secondaryLabel)
                            }
                        }
                        
                        HStack(spacing: 10) {
                            Text("3.", font: .bodyBold).textColor(.systemBlue)
                            VStack(spacing: 4) {
                                Text("Prefer capturing local variables", font: .body)
                                Text("Copy values/objects to local vars in updateProperties()", font: .caption).textColor(.secondaryLabel)
                            }
                        }
                        
                        HStack(spacing: 10) {
                            Text("4.", font: .bodyBold).textColor(.systemBlue)
                            VStack(spacing: 4) {
                                Text("Extract values when possible", font: .body)
                                Text("Value types (Int, Double, CGFloat) are safe to capture", font: .caption).textColor(.secondaryLabel)
                            }
                        }

                        Text("This applies to all escaping closures in UIComponent, not just ConstraintReader!", font: .body).textColor(.secondaryLabel)
                    }.inset(16).backgroundColor(.systemBlue.withAlphaComponent(0.1)).cornerRadius(12)
                }
            }
            
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}

