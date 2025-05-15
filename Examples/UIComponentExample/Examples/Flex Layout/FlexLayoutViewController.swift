//  Created by y H on 2021/7/18.

import UIComponent
import UIKit

class FlexLayoutViewController: ComponentViewController {

    override var component: any Component {

        VStack(spacing: 20) {
            Text("Flex layouts").font(.boldSystemFont(ofSize: 20)).size(width: .fill)

            VStack(spacing: 10) {
                Text("Horizontal layouts")
                VStack(spacing: 10) {
                    Text("FlexRow justify=spaceBetween")
                    FlexRow(spacing: 10, justifyContent: .spaceBetween) {
                        for index in 0...10 {
                            Box(index)
                        }
                    }
                }
                .inset(10).styleColor(.systemGray4).size(width: .fill)

                VStack {
                    Text("HStack (can scroll horizontally)").inset(top: 10, left: 10, bottom: 0, right: 10)
                    HStack(spacing: 10) {
                        for index in 0...10 {
                            Box(index)
                        }
                    }
                    .inset(10).scrollView().showsHorizontalScrollIndicator(false)
                }
                .styleColor(.systemGray4)
            }
            .inset(10).styleColor(.systemGroupedBackground)

            VStack(spacing: 10) {
                Text("Vertical layouts")
                HStack(justifyContent: .spaceBetween) {
                    VStack {
                        Text("FlexColumn")
                        Space(height: 10)
                        FlexColumn(spacing: 10) {
                            for index in 0...10 {
                                Box(index)
                            }
                        }
                        .size(height: 290)
                    }
                    .inset(10).styleColor(.systemGray4)
                    Spacer()
                    VStack {
                        Space(height: 10)
                        Text("VStack")
                        VStack(spacing: 10) {
                            for index in 0...10 {
                                Box(index)
                            }
                        }
                        .inset(10).scrollView().showsVerticalScrollIndicator(false).size(height: 310)
                    }
                    .inset(h: 10).styleColor(.systemGray4)
                }
            }
            .inset(10).styleColor(.systemGroupedBackground)

            VStack(spacing: 10) {
                Text("Justify Content").font(.boldSystemFont(ofSize: 20)).size(width: .fill)
                for justifyContent in MainAxisAlignment.allCases {
                    Text("\(justifyContent)").size(width: .fill)
                    Flow(justifyContent: justifyContent) {
                        for index in 0..<10 {
                            Box(index)
                        }
                    }
                    .inset(10).styleColor(.systemGroupedBackground)
                }
            }

            VStack(spacing: 10) {
                Text("Align Items").font(.boldSystemFont(ofSize: 20)).size(width: .fill)
                for alignItems in CrossAxisAlignment.allCases {
                    Text("\(alignItems)").size(width: .fill)
                    Flow(alignItems: alignItems) {
                        for index in 0..<10 {
                            Box(index, height: 50 + CGFloat(index % 4) * 10)
                        }
                    }
                    .inset(10).styleColor(.systemGroupedBackground)
                }
            }

            VStack(spacing: 10) {
                Text("Align Content").font(.boldSystemFont(ofSize: 20)).size(width: .fill)
                for alignContent in MainAxisAlignment.allCases {
                    Text("\(alignContent)").size(width: .fill)
                    Flow(alignContent: alignContent) {
                        for index in 0..<10 {
                            Box(index, height: 50)
                        }
                    }
                    .size(height: 150).inset(10).styleColor(.systemGroupedBackground)
                }
            }

            VStack(spacing: 10) {
                Text("Flex").font(.boldSystemFont(ofSize: 20)).size(width: .fill)
                Text("single flex").size(width: .fill)
                Flow {
                    Box(1)
                    Box(2).flex()
                    Box(3)
                }
                .inset(10).styleColor(.systemGroupedBackground)
                Text("single flex with spacing").size(width: .fill)
                Flow(spacing: 20) {
                    Box(1)
                    Box(2).flex()
                    Box(3)
                }
                .inset(10).styleColor(.systemGroupedBackground)
                Text("2 flex").size(width: .fill)
                Flow {
                    Box(1)
                    Box(2).flex()
                    Box(3).flex()
                    Box(4)
                }
                .inset(10).styleColor(.systemGroupedBackground)
                Text("2 flex on 1st line").size(width: .fill)
                Flow {
                    Box(1)
                    Box(2).flex()
                    Box(3).flex()
                    Box(4)
                }
                .size(width: 190).inset(10).styleColor(.systemGroupedBackground)
                Text("2 flex on 2nd line").size(width: .fill)
                Flow {
                    Box(1)
                    Box(2)
                    Box(3)
                    Box(4).flex()
                    Box(5).flex()
                }
                .size(width: 190).inset(10).styleColor(.systemGroupedBackground)
            }

            VStack(spacing: 10) {
                Text("Flex align-self").font(.boldSystemFont(ofSize: 20))

                for align in CrossAxisAlignment.allCases {
                    Text("number 1 align-self \(align)").size(width: .fill)
                    Flow {
                        Box(1).flex(alignSelf: align)
                        Box(2, height: 60)
                        Box(3, height: 70)
                        Box(4, height: 80)
                    }
                    .size(width: 190).inset(10).styleColor(.systemGroupedBackground)
                }

            }

        }
        .inset(20)
    }
}
