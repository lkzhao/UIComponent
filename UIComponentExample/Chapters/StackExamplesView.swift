//
//  StackExamplesView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/5/25.
//

import UIComponent

class StackExamplesView: UIView {
    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 40) {
            Text("VStack and HStack Examples", font: .title)
            
            VStack(spacing: 10) {
                Text("VStack basics", font: .subtitle)
                Text("VStack arranges components vertically. You can control spacing between items.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    VStack(spacing: 10) {
                        Text("Item 1")
                        Text("Item 2")
                        Text("Item 3")
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("HStack basics", font: .subtitle)
                Text("HStack arranges components horizontally. Works similar to VStack but in horizontal direction.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    HStack(spacing: 10) {
                        Text("Item 1")
                        Text("Item 2")
                        Text("Item 3")
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("Main axis alignment (justifyContent)", font: .subtitle)
                Text("Controls how items are distributed along the main axis.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("justifyContent: .start (default)", font: .caption)
                    #CodeExample(
                        HStack(justifyContent: .start) {
                            Text("A").inset(8).backgroundColor(.systemBlue)
                            Text("B").inset(8).backgroundColor(.systemBlue)
                            Text("C").inset(8).backgroundColor(.systemBlue)
                        }.size(width: .fill)
                    )
                    
                    Text("justifyContent: .end", font: .caption)
                    #CodeExample(
                        HStack(justifyContent: .end) {
                            Text("A").inset(8).backgroundColor(.systemBlue)
                            Text("B").inset(8).backgroundColor(.systemBlue)
                            Text("C").inset(8).backgroundColor(.systemBlue)
                        }.size(width: .fill)
                    )
                    
                    Text("justifyContent: .center", font: .caption)
                    #CodeExample(
                        HStack(justifyContent: .center) {
                            Text("A").inset(8).backgroundColor(.systemBlue)
                            Text("B").inset(8).backgroundColor(.systemBlue)
                            Text("C").inset(8).backgroundColor(.systemBlue)
                        }.size(width: .fill)
                    )
                    
                    Text("justifyContent: .spaceBetween", font: .caption)
                    #CodeExample(
                        HStack(justifyContent: .spaceBetween) {
                            Text("A").inset(8).backgroundColor(.systemBlue)
                            Text("B").inset(8).backgroundColor(.systemBlue)
                            Text("C").inset(8).backgroundColor(.systemBlue)
                        }.size(width: .fill)
                    )
                    
                    Text("justifyContent: .spaceAround", font: .caption)
                    #CodeExample(
                        HStack(justifyContent: .spaceAround) {
                            Text("A").inset(8).backgroundColor(.systemBlue)
                            Text("B").inset(8).backgroundColor(.systemBlue)
                            Text("C").inset(8).backgroundColor(.systemBlue)
                        }.size(width: .fill)
                    )
                    
                    Text("justifyContent: .spaceEvenly", font: .caption)
                    #CodeExample(
                        HStack(justifyContent: .spaceEvenly) {
                            Text("A").inset(8).backgroundColor(.systemBlue)
                            Text("B").inset(8).backgroundColor(.systemBlue)
                            Text("C").inset(8).backgroundColor(.systemBlue)
                        }.size(width: .fill)
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Cross axis alignment (alignItems)", font: .subtitle)
                Text("Controls how items align perpendicular to the main axis.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("alignItems: .start (default)", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Text("Small", font: .body).inset(8).backgroundColor(.systemBlue)
                            Text("Big", font: .title).inset(8).backgroundColor(.systemBlue)
                            Text("Medium", font: .subtitle).inset(8).backgroundColor(.systemBlue)
                        }.size(height: 80)
                    )
                    
                    Text("alignItems: .end", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10, alignItems: .end) {
                            Text("Small", font: .body).inset(8).backgroundColor(.systemBlue)
                            Text("Big", font: .title).inset(8).backgroundColor(.systemBlue)
                            Text("Medium", font: .subtitle).inset(8).backgroundColor(.systemBlue)
                        }.size(height: 80)
                    )
                    
                    Text("alignItems: .center", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10, alignItems: .center) {
                            Text("Small", font: .body).inset(8).backgroundColor(.systemBlue)
                            Text("Big", font: .title).inset(8).backgroundColor(.systemBlue)
                            Text("Medium", font: .subtitle).inset(8).backgroundColor(.systemBlue)
                        }.size(height: 80)
                    )
                    
                    Text("alignItems: .stretch", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10, alignItems: .stretch) {
                            Text("Small", font: .body).inset(8).backgroundColor(.systemBlue)
                            Text("Big", font: .title).inset(8).backgroundColor(.systemBlue)
                            Text("Medium", font: .subtitle).inset(8).backgroundColor(.systemBlue)
                        }.size(height: 80)
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Align self", font: .subtitle)
                Text("Individual items can override the parent's alignItems alignment using the alignSelf modifier.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("HStack with alignSelf", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Text("Default")
                                .inset(8)
                                .backgroundColor(.systemBlue)
                            
                            Text("Center")
                                .inset(8)
                                .backgroundColor(.systemGreen)
                                .alignSelf(.center)
                            
                            Text("End")
                                .inset(8)
                                .backgroundColor(.systemOrange)
                                .alignSelf(.end)
                            
                            Text("Stretch")
                                .inset(8)
                                .backgroundColor(.systemPurple)
                                .alignSelf(.stretch)
                        }.size(height: 100)
                    )
                    
                    Text("VStack with alignSelf", font: .caption)
                    #CodeExample(
                        VStack(spacing: 10) {
                            Text("Default (start)")
                                .inset(8)
                                .backgroundColor(.systemBlue)
                            
                            Text("Center")
                                .inset(8)
                                .backgroundColor(.systemGreen)
                                .alignSelf(.center)
                            
                            Text("End")
                                .inset(8)
                                .backgroundColor(.systemOrange)
                                .alignSelf(.end)
                            
                            Text("Stretch")
                                .inset(8)
                                .backgroundColor(.systemPurple)
                                .alignSelf(.stretch)
                        }.size(width: 200)
                    )
                }
            }
            
            VStack(spacing: 10) {
                Text("Using loops", font: .subtitle)
                Text("You can use standard Swift for-in loops to generate components dynamically.", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    VStack(spacing: 8) {
                        for i in 1...5 {
                            HStack(spacing: 4) {
                                Image(systemName: "\(i).circle").tintColor(.systemBlue)
                                Text("Item \(i)")
                            }
                        }
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("Using Join", font: .subtitle)
                Text("Join allows you to insert separators between components. Perfect for lists with dividers.", font: .body).textColor(.secondaryLabel)
                #CodeExampleNoInsets(
                    VStack {
                        Join {
                            for item in ["Apple", "Orange", "Banana"] {
                                Text(item).inset(h: 16, v: 10)
                            }
                        } separator: {
                            Separator().inset(h: 16)
                        }
                    }
                )
            }
            
            VStack(spacing: 10) {
                Text("Nested stacks", font: .subtitle)
                Text("Combine VStack and HStack to create complex layouts. The .flex() modifier makes the middle VStack grow to fill available space (see Flex Modifiers chapter for details).", font: .body).textColor(.secondaryLabel)
                #CodeExample(
                    HStack(spacing: 10, alignItems: .center) {
                        Image(systemName: "person.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)).tintColor(.systemBlue)
                        VStack(spacing: 4) {
                            Text("John Doe", font: .bodyBold)
                            Text("john.doe@example.com", font: .body).textColor(.secondaryLabel)
                        }.flex()
                        Image(systemName: "chevron.right").tintColor(.tertiaryLabel)
                    }
                )
            }
        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}
