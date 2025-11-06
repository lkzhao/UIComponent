//
//  FlexExamplesView.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/5/25.
//

import UIComponent

class FlexExamplesView: UIView {
    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 40) {
            Text("Flex Modifiers", font: .title)

            VStack(spacing: 10) {
                Text("Flex modifiers control how components grow and shrink to adapt to available space. \nThey work with HStack, VStack, and Flow layouts.", font: .body)
                VStack(spacing: 8) {
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .tintColor(.systemBlue)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("flexGrow - expand to fill extra space", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                            .tintColor(.systemOrange)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("flexShrink - compress when space is limited", font: .body)
                    }
                    HStack(spacing: 8, alignItems: .center) {
                        Image(systemName: "arrow.left.and.right")
                            .tintColor(.systemGreen)
                            .contentMode(.center)
                            .size(width: 24, height: 24)
                        Text("flex - combines both grow and shrink", font: .body)
                    }
                }.inset(16).backgroundColor(.systemGray6).cornerRadius(12)
            }

            VStack(spacing: 10) {
                Text("Flex grow basics", font: .subtitle)
                Text("flexGrow makes items expand to fill available space. Higher values claim more space proportionally.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("HStack with flexGrow", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Text("Fixed")
                                .inset(8)
                                .backgroundColor(.systemBlue)

                            Text("Grows 1x")
                                .inset(8)
                                .backgroundColor(.systemGreen)
                                .flexGrow(1)

                            Text("Fixed")
                                .inset(8)
                                .backgroundColor(.systemBlue)
                        }.size(width: .fill)
                    )

                    Text("VStack with flexGrow", font: .caption)
                    #CodeExample(
                        VStack(spacing: 10) {
                            Text("Fixed")
                                .inset(8)
                                .backgroundColor(.systemBlue)

                            Text("Grows")
                                .inset(8)
                                .backgroundColor(.systemGreen)
                                .flexGrow(1)

                            Text("Fixed")
                                .inset(8)
                                .backgroundColor(.systemBlue)
                        }.size(height: 200)
                    )

                    Text("Flow Layout with flexGrow", font: .caption)
                    Text("flexGrow in Flow makes items expand within each row to fill available space.", font: .caption).textColor(.secondaryLabel)
                    #CodeExample(
                        Flow(spacing: 8) {
                            Text("Fixed")
                                .inset(h: 12, v: 8)
                                .backgroundColor(.systemBlue)

                            Text("Grows")
                                .inset(h: 12, v: 8)
                                .backgroundColor(.systemGreen)
                                .flexGrow(1)

                            Text("Fixed")
                                .inset(h: 12, v: 8)
                                .backgroundColor(.systemBlue)

                            Text("Fixed")
                                .inset(h: 12, v: 8)
                                .backgroundColor(.systemBlue)

                            Text("Grows")
                                .inset(h: 12, v: 8)
                                .backgroundColor(.systemGreen)
                                .flexGrow(1)

                            Text("Fixed")
                                .inset(h: 12, v: 8)
                                .backgroundColor(.systemBlue)
                        }.size(width: 300)
                    )
                }
            }

            VStack(spacing: 10) {
                Text("Flex grow ratios", font: .subtitle)
                Text("Different flexGrow values create proportional size relationships.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("Equal ratios (1:1:1)", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Text("1x")
                                .inset(8)
                                .backgroundColor(.systemGreen)
                                .flexGrow(1)

                            Text("1x")
                                .inset(8)
                                .backgroundColor(.systemGreen)
                                .flexGrow(1)

                            Text("1x")
                                .inset(8)
                                .backgroundColor(.systemGreen)
                                .flexGrow(1)
                        }.size(width: .fill)
                    )

                    Text("Different ratios (1:3:2)", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Text("1x")
                                .inset(8)
                                .backgroundColor(.systemGreen)
                                .flexGrow(1)

                            Text("3x")
                                .inset(8)
                                .backgroundColor(.systemRed)
                                .flexGrow(3)

                            Text("2x")
                                .inset(8)
                                .backgroundColor(.systemOrange)
                                .flexGrow(2)
                        }.size(width: .fill)
                    )
                }
            }

            VStack(spacing: 10) {
                Text("Flex shrink basics", font: .subtitle)
                Text("flexShrink makes items compress when space is limited. Higher values shrink more.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("Without flexShrink (overflow)", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Space(width: 130, height: 50)
                                .backgroundColor(.systemBlue)

                            Space(width: 130, height: 50)
                                .backgroundColor(.systemBlue)

                            Space(width: 130, height: 50)
                                .backgroundColor(.systemBlue)
                        }.size(width: 300)
                    )

                    Text("With flexShrink (fits)", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Space(width: 130, height: 50)
                                .backgroundColor(.systemGreen)
                                .flexShrink(1)

                            Space(width: 130, height: 50)
                                .backgroundColor(.systemGreen)
                                .flexShrink(1)

                            Space(width: 130, height: 50)
                                .backgroundColor(.systemGreen)
                                .flexShrink(1)
                        }.size(width: 300)
                    )
                }
            }

            VStack(spacing: 10) {
                Text("Flex shrink ratios", font: .subtitle)
                Text("Different flexShrink values control which items compress more.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("One item won't shrink", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Space(width: 130, height: 50)
                                .backgroundColor(.systemPurple)
                                .overlay {
                                    Text("Shrink 1x").textAlignment(.center)
                                }
                                .flexShrink(1)

                            Space(width: 130, height: 50)
                                .backgroundColor(.systemBlue)
                                .overlay {
                                    Text("No shrink").textAlignment(.center)
                                }

                            Space(width: 130, height: 50)
                                .backgroundColor(.systemPurple)
                                .overlay {
                                    Text("Shrink 1x").textAlignment(.center)
                                }
                                .flexShrink(1)
                        }.size(width: 300)
                    )

                    Text("Different shrink ratios (1:2:0)", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Space(width: 130, height: 50)
                                .backgroundColor(.systemPurple)
                                .overlay {
                                    Text("1x").textAlignment(.center)
                                }
                                .flexShrink(1)

                            Space(width: 130, height: 50)
                                .backgroundColor(.systemOrange)
                                .overlay {
                                    Text("2x").textAlignment(.center)
                                }
                                .flexShrink(2)

                            Space(width: 130, height: 50)
                                .backgroundColor(.systemBlue)
                                .overlay {
                                    Text("0x").textAlignment(.center)
                                }
                        }.size(width: 300)
                    )
                }
            }

            VStack(spacing: 10) {
                Text("The .flex() modifier", font: .subtitle)
                Text("The .flex() modifier combines both flexGrow and flexShrink, making items truly flexible. They expand when there's extra space and compress when space is limited.", font: .body).textColor(.secondaryLabel)
                VStack(spacing: 10) {
                    Text("Grows to fill space", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Space(width: 80, height: 50)
                                .backgroundColor(.systemBlue)
                                .overlay {
                                    Text("Fixed").textAlignment(.center)
                                }

                            Space(width: 80, height: 50)
                                .backgroundColor(.systemGreen)
                                .overlay {
                                    Text("Flexible").textAlignment(.center)
                                }
                                .flex()

                            Space(width: 80, height: 50)
                                .backgroundColor(.systemBlue)
                                .overlay {
                                    Text("Fixed").textAlignment(.center)
                                }
                        }.size(width: .fill)
                    )

                    Text("Shrinks when constrained", font: .caption)
                    #CodeExample(
                        HStack(spacing: 10) {
                            Space(width: 80, height: 50)
                                .backgroundColor(.systemBlue)
                                .overlay {
                                    Text("Fixed").textAlignment(.center)
                                }

                            Space(width: 80, height: 50)
                                .backgroundColor(.systemGreen)
                                .overlay {
                                    Text("Flexible").textAlignment(.center)
                                }
                                .flex()

                            Space(width: 80, height: 50)
                                .backgroundColor(.systemBlue)
                                .overlay {
                                    Text("Fixed").textAlignment(.center)
                                }
                        }.size(width: 250)
                    )
                }
            }

            VStack(spacing: 10) {
                Text("Practical Examples", font: .subtitle)
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text("Profile card with flex", font: .caption)
                        #CodeExample(
                            HStack(spacing: 10, alignItems: .center) {
                                Image(systemName: "person.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
                                    .tintColor(.systemBlue)

                                VStack(spacing: 4, alignItems: .start) {
                                    Text("John Doe", font: .bodyBold)
                                    Text("john.doe@example.com", font: .body)
                                        .textColor(.secondaryLabel)
                                }
                                .flex()

                                Image(systemName: "chevron.right")
                                    .tintColor(.tertiaryLabel)
                            }.inset(16).backgroundColor(.systemGray6)
                        )
                    }

                    VStack(spacing: 10) {
                        Text("Toolbar with flexible spacer", font: .caption)
                        #CodeExample(
                            HStack(spacing: 10, alignItems: .center) {
                                Image(systemName: "line.3.horizontal")
                                    .tintColor(.label)

                                Text("Title", font: .bodyBold)

                                // Same as Space().flex()
                                Spacer()

                                Image(systemName: "magnifyingglass")
                                    .tintColor(.label)

                                Image(systemName: "ellipsis")
                                    .tintColor(.label)
                            }.inset(h: 16, v: 12).backgroundColor(.systemGray6)
                        )
                    }

                    VStack(spacing: 10) {
                        Text("Form field with label", font: .caption)
                        #CodeExample(
                            VStack(spacing: 16) {
                                HStack(spacing: 10, alignItems: .center) {
                                    Text("Name:", font: .body)
                                        .size(width: 64)

                                    Text("John Doe", font: .body)
                                        .inset(h: 12, v: 8)
                                        .backgroundColor(.systemGray5)
                                        .cornerRadius(8)
                                        .flex()
                                }

                                HStack(spacing: 10, alignItems: .center) {
                                    Text("Email:", font: .body)
                                        .size(width: 64)

                                    Text("john@example.com", font: .body)
                                        .inset(h: 12, v: 8)
                                        .backgroundColor(.systemGray5)
                                        .cornerRadius(8)
                                        .flex()
                                }
                            }.inset(16)
                        )
                    }

                    VStack(spacing: 10) {
                        Text("Use flex to archive same width buttons", font: .body).textColor(.secondaryLabel)
                        Text("Wide container:", font: .caption)
                        #CodeExample(
                            HStack(spacing: 10) {
                                Text("Cancel", font: .body)
                                    .textAlignment(.center)
                                    .inset(h: 20, v: 10)
                                    .backgroundColor(.systemGray5)
                                    .cornerRadius(8)
                                    .flex()

                                Text("Save", font: .body)
                                    .textAlignment(.center)
                                    .inset(h: 20, v: 10)
                                    .backgroundColor(.systemBlue)
                                    .textColor(.white)
                                    .cornerRadius(8)
                                    .flex()
                            }
                        )
                    }

                    VStack(spacing: 10) {
                        Text("Narrow container:", font: .caption)
                        #CodeExample(
                            HStack(spacing: 10) {
                                Text("Cancel", font: .body)
                                    .textAlignment(.center)
                                    .inset(h: 20, v: 10)
                                    .backgroundColor(.systemGray5)
                                    .cornerRadius(8)
                                    .flex()

                                Text("Save", font: .body)
                                    .textAlignment(.center)
                                    .inset(h: 20, v: 10)
                                    .backgroundColor(.systemBlue)
                                    .textColor(.white)
                                    .cornerRadius(8)
                                    .flex()
                            }.size(width: 200)
                        )
                    }
                }
            }

        }.inset(24).ignoreHeightConstraint().scrollView().contentInsetAdjustmentBehavior(.always).fill()
    }
}

