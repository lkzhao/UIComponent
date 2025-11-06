//
//  SizingAndConstraintExamplesView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/5/25.
//

import UIComponent

class SizingAndConstraintExamplesView: UIView {
    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 40) {
            Text("Sizing and Constraint Examples", font: .title)
            
            VStack(spacing: 10) {
                Text("Overview", font: .subtitle)
                Text("UIComponent provides powerful sizing modifiers to control component dimensions. Understanding these modifiers is essential for building responsive layouts.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 8) {
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .tintColor(.systemBlue)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text(".size - sets component dimensions", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.down.backward.square")
                            .tintColor(.systemOrange)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text(".maxSize - limits maximum dimensions", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.up.forward.square")
                            .tintColor(.systemGreen)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text(".minSize - ensures minimum dimensions", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "slider.horizontal.3")
                            .tintColor(.systemPurple)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text(".constraint - custom constraint logic", font: .body)
                    }
                }.inset(16).backgroundColor(.systemGray6).cornerRadius(12)
            }
            
            // MARK: - .size modifier basics
            
            VStack(spacing: 10) {
                Text(".size modifier basics", font: .subtitle)
                Text("The .size modifier allows you to set fixed dimensions for components.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("Fixed width and height", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Text("100x50")
                                .textAlignment(.center)
                                .backgroundColor(.systemBlue)
                                .size(width: 100, height: 50)
                            
                            Text("80x80")
                                .textAlignment(.center)
                                .backgroundColor(.systemGreen)
                                .size(width: 80, height: 80)
                            
                            Text("120x40")
                                .textAlignment(.center)
                                .backgroundColor(.systemOrange)
                                .size(width: 120, height: 40)
                        }.inset(10)
                    )
                    
                    Text("Using CGSize", font: .caption)
                    #CodeExample(
                        Text("CGSize(100, 100)")
                            .textAlignment(.center)
                            .backgroundColor(.systemPurple)
                            .size(CGSize(width: 100, height: 100))
                            .inset(10)
                    )
                    
                    Text("Fixed width only", font: .caption)
                    #CodeExample(
                        VStack(spacing: 8) {
                            Text("Fixed width (120), height fits content")
                                .backgroundColor(.systemIndigo)
                                .inset(10)
                                .size(width: 120)
                            
                            Text("Another example with more text that wraps around")
                                .backgroundColor(.systemTeal)
                                .inset(10)
                                .size(width: 120)
                        }
                    )
                    
                    Text("Fixed height only", font: .caption)
                    #CodeExample(
                        HStack(spacing: 8) {
                            Text("Height 60")
                                .inset(10)
                                .backgroundColor(.systemPink)
                                .size(height: 60)
                            
                            Text("Also 60")
                                .inset(10)
                                .backgroundColor(.systemMint)
                                .size(height: 60)
                        }
                    )
                }
            }
            
            // MARK: - SizeStrategy
            
            VStack(spacing: 10) {
                Text("SizeStrategy: .fit vs .fill", font: .subtitle)
                Text("SizeStrategy determines how components size themselves within available space.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text(".fit (default)", font: .caption)
                    Text("Component sizes to its intrinsic content size.", font: .caption).textColor(.secondaryLabel)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Text("Fit")
                                .inset(10)
                                .backgroundColor(.systemBlue)
                                .size(width: .fit, height: .fit)
                            
                            Text("Fit")
                                .inset(10)
                                .backgroundColor(.systemBlue)
                                .size(width: .fit, height: .fit)
                        }.inset(10).backgroundColor(.systemGray6)
                    )
                    
                    Text(".fill", font: .caption)
                    Text("Component expands to fill available space.", font: .caption).textColor(.secondaryLabel)
                    #CodeExample(
                        VStack(spacing: 10) {
                            Text("Fills width")
                                .textAlignment(.center)
                                .inset(10)
                                .backgroundColor(.systemGreen)
                                .size(width: .fill)
                            
                            Text("Fits width")
                                .inset(10)
                                .backgroundColor(.systemOrange)
                                .size(width: .fit) // can be ignored since fit is default
                        }.inset(10).backgroundColor(.systemGray6)
                    )
                    
                    Text(".fit() and .fill() shortcuts", font: .caption)
                    #CodeExample(
                        VStack(spacing: 10) {
                            Text("Using .fill()")
                                .textAlignment(.center)
                                .inset(10)
                                .backgroundColor(.systemBlue)
                                .fill()
                            
                            HStack(spacing: 10) {
                                Text("Using .fit()")
                                    .inset(10)
                                    .backgroundColor(.systemGreen)
                                    .fit() // can be ignored since fit is default

                                Text("Also .fit()")
                                    .inset(10)
                                    .backgroundColor(.systemOrange)
                                    .fit() // can be ignored since fit is default
                            }
                        }.inset(10).backgroundColor(.systemGray6)
                    )
                }
            }
            
            // MARK: - Percentage sizing
            
            VStack(spacing: 10) {
                Text("SizeStrategy: Percentage sizing", font: .subtitle)
                Text("Use .percentage to size components relative to available space.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("Width percentages", font: .caption)
                    #CodeExample(
                        VStack(spacing: 10) {
                            Text("50% width")
                                .textAlignment(.center)
                                .inset(8)
                                .backgroundColor(.systemBlue)
                                .size(width: .percentage(0.5))
                            
                            Text("75% width")
                                .textAlignment(.center)
                                .inset(8)
                                .backgroundColor(.systemGreen)
                                .size(width: .percentage(0.75))
                            
                            Text("100% width")
                                .textAlignment(.center)
                                .inset(8)
                                .backgroundColor(.systemOrange)
                                .size(width: .percentage(1.0))
                        }.inset(10).backgroundColor(.systemGray6)
                    )
                    
                    Text("Combining percentage and absolute", font: .caption)
                    #CodeExample(
                        VStack(spacing: 10) {
                            Text("33%")
                                .textAlignment(.center)
                                .inset(8)
                                .backgroundColor(.systemPurple)
                                .size(width: .percentage(0.33), height: 60)
                        }.inset(10).size(width: 300)
                    )
                }
            }
            
            // MARK: - Aspect ratio
            
            VStack(spacing: 10) {
                Text("SizeStrategy: Aspect ratio sizing", font: .subtitle)
                Text("Use .aspectPercentage to maintain aspect ratios.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("Square (1:1 ratio)", font: .caption)
                    #CodeExample(
                        VStack(spacing: 10) {
                            Space(width: 100, height: 100)
                                .backgroundColor(.systemBlue)
                                .size(width: 100, height: .aspectPercentage(1.0))
                                .overlay {
                                    Text("100x100").textAlignment(.center)
                                }
                            
                            Space(width: 150, height: 150)
                                .backgroundColor(.systemGreen)
                                .size(width: 150, height: .aspectPercentage(1.0))
                                .overlay {
                                    Text("150x150").textAlignment(.center)
                                }
                        }
                    )
                    
                    Text("16:9 aspect ratio", font: .caption)
                    #CodeExample(
                        Space(width: 200, height: 112.5)
                            .backgroundColor(.systemPurple)
                            .size(width: 200, height: .aspectPercentage(9.0/16.0))
                            .overlay {
                                Text("16:9 Video").textAlignment(.center).textColor(.white)
                            }
                            .inset(10)
                    )
                    
                    Text("4:3 aspect ratio", font: .caption)
                    #CodeExample(
                        Space(width: 200, height: 150)
                            .backgroundColor(.systemOrange)
                            .size(width: 200, height: .aspectPercentage(3.0/4.0))
                            .overlay {
                                Text("4:3 Photo").textAlignment(.center).textColor(.white)
                            }
                            .inset(10)
                    )
                }
            }
            
            // MARK: - maxSize modifier
            
            VStack(spacing: 10) {
                Text(".maxSize modifier", font: .subtitle)
                Text("maxSize limits the maximum dimensions a component can grow to.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("Without maxSize", font: .caption)
                    #CodeExample(
                        Text("This is a very long text that will take up as much width as available in the container without any size restrictions")
                            .inset(10)
                            .backgroundColor(.systemBlue)
                    )
                    
                    Text("With maxSize width", font: .caption)
                    #CodeExample(
                        Text("This is a very long text that will wrap because it has a maximum width constraint applied")
                            .inset(10)
                            .backgroundColor(.systemGreen)
                            .maxSize(width: 200)
                    )
                    
                    Text("Max width and height", font: .caption)
                    #CodeExample(
                        VStack(spacing: 10) {
                            for i in 1...10 {
                                Text("Item \(i)").inset(8)
                            }
                        }
                        .backgroundColor(.systemBlue)
                        .maxSize(width: 150, height: 120)
                        .inset(10)
                    )
                }
            }
            
            // MARK: - minSize modifier
            
            VStack(spacing: 10) {
                Text(".minSize modifier", font: .subtitle)
                Text("minSize ensures components meet minimum dimension requirements.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("Without minSize", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Text("A")
                                .inset(8)
                                .backgroundColor(.systemRed)
                            
                            Text("Longer")
                                .inset(8)
                                .backgroundColor(.systemRed)
                        }.inset(10)
                    )
                    
                    Text("With minSize width", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Text("A")
                                .inset(8)
                                .backgroundColor(.systemGreen)
                                .minSize(width: 80)
                            
                            Text("Longer")
                                .inset(8)
                                .backgroundColor(.systemGreen)
                                .minSize(width: 80)
                        }.inset(10)
                    )
                    
                    Text("Minimum button sizes", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Text("OK")
                                .textAlignment(.center)
                                .inset(h: 16, v: 8)
                                .backgroundColor(.systemBlue)
                                .cornerRadius(8)
                                .minSize(width: 80, height: 44)
                            
                            Text("Cancel")
                                .textAlignment(.center)
                                .inset(h: 16, v: 8)
                                .backgroundColor(.systemGray5)
                                .cornerRadius(8)
                                .minSize(width: 80, height: 44)
                        }.inset(10)
                    )
                    
                    Text("Touch target minimum", font: .caption)
                    Text("Ensure interactive elements are at least 44x44 points for accessibility.", font: .caption).textColor(.secondaryLabel)
                    #CodeExample(
                        HStack(spacing: 15) {
                            Image(systemName: "heart")
                                .tintColor(.systemRed)
                                .contentMode(.scaleAspectFit)
                                .minSize(width: 44, height: 44)
                                .backgroundColor(.systemGray6)
                            
                            Image(systemName: "star")
                                .tintColor(.systemYellow)
                                .contentMode(.scaleAspectFit)
                                .minSize(width: 44, height: 44)
                                .backgroundColor(.systemGray6)
                            
                            Image(systemName: "bookmark")
                                .tintColor(.systemBlue)
                                .contentMode(.scaleAspectFit)
                                .minSize(width: 44, height: 44)
                                .backgroundColor(.systemGray6)
                        }.inset(10)
                    )
                }
            }
            
            // MARK: - Combining min and max
            
            VStack(spacing: 10) {
                Text("Combining minSize and maxSize", font: .subtitle)
                Text("Use both modifiers together to create flexible but bounded components.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("Responsive card", font: .caption)
                    #CodeExample(
                        VStack(spacing: 10) {
                            Text("Card Title", font: .bodyBold)
                            Text("This card adapts to content but stays within reasonable bounds")
                        }
                        .inset(16)
                        .backgroundColor(.systemBlue.withAlphaComponent(0.1))
                        .cornerRadius(12)
                        .minSize(width: 150, height: 80)
                        .maxSize(width: 300, height: 200)
                    )
                    
                    Text("Flexible sidebar item", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10, alignItems: .center) {
                            Image(systemName: "folder.fill")
                                .tintColor(.systemBlue)
                            
                            Text("Documents")
                                .flex()
                            
                            Text("24")
                                .textColor(.secondaryLabel)
                        }
                        .inset(h: 12, v: 8)
                        .backgroundColor(.systemGray6)
                        .cornerRadius(8)
                        .minSize(width: 120)
                        .maxSize(width: 250)
                    )
                }
            }
            
            // MARK: - .constraint modifier
            
            VStack(spacing: 10) {
                Text(".constraint modifier", font: .subtitle)
                Text("The constraint modifier provides low-level control over component sizing. It receives a Constraint object with minSize and maxSize, and returns a modified Constraint.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("Custom constraint logic", font: .caption)
                    Text("Make height 50% of available width.", font: .caption).textColor(.secondaryLabel)
                    #CodeExample(
                        Space(width: 200, height: 100)
                            .backgroundColor(.systemPurple)
                            .constraint { constraint in
                                let width = constraint.maxSize.width
                                let height = width * 0.5
                                return Constraint(tightSize: CGSize(width: width, height: height))
                            }
                            .overlay {
                                Text("Width:Height = 2:1").textAlignment(.center).textColor(.white)
                            }
                            .inset(10)
                    )
                    
                    Text("Closure-based sizing", font: .caption)
                    Text("The .size modifier also accepts closures for dynamic sizing.", font: .caption).textColor(.secondaryLabel)
                    #CodeExample(
                        Space(width: 100, height: 100)
                            .backgroundColor(.systemIndigo)
                            .size { maxSize in
                                CGSize(width: maxSize.width * 0.6, height: 100)
                            }
                            .overlay {
                                Text("60% width").textAlignment(.center).textColor(.white)
                            }
                            .inset(10)
                    )
                    
                    Text("Fixed constraint", font: .caption)
                    Text("Pass a Constraint object directly.", font: .caption).textColor(.secondaryLabel)
                    #CodeExample(
                        Space(width: 150, height: 75)
                            .backgroundColor(.systemTeal)
                            .constraint(Constraint(tightSize: CGSize(width: 150, height: 75)))
                            .overlay {
                                Text("Tight 150x75").textAlignment(.center).textColor(.white)
                            }
                            .inset(10)
                    )
                }
            }
            
            // MARK: - Practical examples
            
            VStack(spacing: 10) {
                Text("Practical examples", font: .subtitle)
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text("Avatar with size constraints", font: .caption)
                        #CodeExample(
                            HStack(spacing: 12, alignItems: .center) {
                                Image(systemName: "person.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
                                    .tintColor(.systemBlue)
                                    .contentMode(.scaleAspectFit)
                                    .size(width: 50, height: 50)
                                
                                VStack(spacing: 4, alignItems: .start) {
                                    Text("John Doe", font: .bodyBold)
                                    Text("Software Engineer", font: .body)
                                        .textColor(.secondaryLabel)
                                }
                                .flex()
                            }.inset(16).backgroundColor(.systemGray6).cornerRadius(12).maxSize(width: 400)
                        )
                    }
                    
                    VStack(spacing: 10) {
                        Text("Grid of equal-sized items", font: .caption)
                        #CodeExample(
                            VStack(spacing: 10) {
                                HStack(spacing: 10) {
                                    Text("1")
                                        .textAlignment(.center)
                                        .backgroundColor(.systemBlue)
                                        .size(width: 60, height: 60)
                                    
                                    Text("2")
                                        .textAlignment(.center)
                                        .backgroundColor(.systemGreen)
                                        .size(width: 60, height: 60)
                                    
                                    Text("3")
                                        .textAlignment(.center)
                                        .backgroundColor(.systemOrange)
                                        .size(width: 60, height: 60)
                                }
                                
                                HStack(spacing: 10) {
                                    Text("4")
                                        .textAlignment(.center)
                                        .backgroundColor(.systemPurple)
                                        .size(width: 60, height: 60)
                                    
                                    Text("5")
                                        .textAlignment(.center)
                                        .backgroundColor(.systemPink)
                                        .size(width: 60, height: 60)
                                    
                                    Text("6")
                                        .textAlignment(.center)
                                        .backgroundColor(.systemIndigo)
                                        .size(width: 60, height: 60)
                                }
                            }.inset(10)
                        )
                    }
                    
                    VStack(spacing: 10) {
                        Text("Toolbar with sized buttons", font: .caption)
                        #CodeExample(
                            HStack(spacing: 12, alignItems: .center) {
                                Text("Cancel")
                                    .textAlignment(.center)
                                    .textColor(.label)
                                    .inset(h: 16, v: 10)
                                    .backgroundColor(.systemGray5)
                                    .cornerRadius(8)
                                    .minSize(width: 80, height: 44)
                                
                                Spacer()
                                
                                Text("Save")
                                    .textAlignment(.center)
                                    .textColor(.white)
                                    .inset(h: 16, v: 10)
                                    .backgroundColor(.systemBlue)
                                    .cornerRadius(8)
                                    .minSize(width: 80, height: 44)
                            }.inset(16).backgroundColor(.systemGray6)
                        )
                    }
                    
                    VStack(spacing: 10) {
                        Text("Card with flexible content area", font: .caption)
                        #CodeExample(
                            VStack(spacing: 0, alignItems: .start) {
                                Image(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
                                    .tintColor(.systemGray)
                                    .contentMode(.scaleAspectFit)
                                    .size(width: .fill, height: 120)
                                    .backgroundColor(.systemGray6)
                                
                                VStack(spacing: 8, alignItems: .start) {
                                    Text("Card Title", font: .bodyBold)
                                    Text("This is a description that adapts to the card width but respects min/max constraints")
                                        .textColor(.secondaryLabel)
                                }
                                .inset(16)
                            }
                            .backgroundColor(.systemBackground)
                            .cornerRadius(12)
                            .minSize(width: 200)
                            .maxSize(width: 350)
                        )
                    }
                }
            }
            
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}

