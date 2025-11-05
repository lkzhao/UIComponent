//
//  Chapter.swift
//  UIComponentExample
//
//  Created by Luke Zhao on 11/5/25.
//



struct Chapter: Equatable {
    let title: String
    let view: UIView.Type

    static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        lhs.title == rhs.title && lhs.view == rhs.view
    }

    static let all: [Chapter] = [
        Chapter(
            title: "Getting Started",
            view: GettingStartedView.self
        ),
        Chapter(
            title: "Simple Examples",
            view: SimpleExamplesView.self
        ),
        Chapter(
            title: "VStack / HStack",
            view: StackExamplesView.self
        ),
        Chapter(
            title: "ZStack",
            view: ZStackExamplesView.self
        ),
        Chapter(
            title: "Placement",
            view: PlacementExamplesView.self
        ),
        Chapter(
            title: "Custom View",
            view: CustomViewExamplesView.self
        ),
    ]
}
