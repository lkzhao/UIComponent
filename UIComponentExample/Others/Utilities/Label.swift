//  Created by y H on 2025/6/25.
//  Copyright © 2025 wwdc14yh. All rights reserved.

import UIComponent

public protocol LabelStyle {
    typealias Configuration = Label.StyleConfiguration
    associatedtype C: Component

    func makeBody(configuration: Self.Configuration) -> Self.C
}

public struct DefaultLabelStyle: LabelStyle {
    public func makeBody(configuration: Configuration) -> some Component {
        HStack(spacing: 5, alignItems: .center) {
            configuration.icon
            configuration.title
        }
    }
}

public extension LabelStyle where Self == DefaultLabelStyle {
    static var automatic: DefaultLabelStyle {
        DefaultLabelStyle()
    }
}

public struct IconOnlyLabelStyle: LabelStyle {
    public func makeBody(configuration: Configuration) -> some Component {
        configuration.icon
            .eraseToAnyComponent()
    }
}

public extension LabelStyle where Self == IconOnlyLabelStyle {
    static var iconOnly: IconOnlyLabelStyle {
        IconOnlyLabelStyle()
    }
}

public struct TitleOnlyLabelStyle: LabelStyle {
    public func makeBody(configuration: Configuration) -> some Component {
        configuration.title
            .eraseToAnyComponent()
    }
}

public struct TitleAndIconLabelStyle: LabelStyle {
    public enum Layout {
        case vertical, horizontal

        func makeBody(spacing: CGFloat, alignment: Alignment, @ComponentArrayBuilder content: () -> [any Component]) -> some Component {
            switch self {
            case .vertical:
                VStack(spacing: spacing, alignItems: alignment._tranformCrossAxisAlignment, content)
                    .eraseToAnyComponent()
            case .horizontal:
                HStack(spacing: spacing, alignItems: alignment._tranformCrossAxisAlignment, content)
                    .eraseToAnyComponent()
            }
        }
    }

    public enum Alignment {
        case left, center, right

        var _tranformCrossAxisAlignment: CrossAxisAlignment {
            switch self {
            case .left: .start
            case .center: .center
            case .right: .end
            }
        }
    }

    let layout: Layout
    let alignment: Alignment
    let isReversal: Bool
    let spacing: CGFloat

    public func makeBody(configuration: Configuration) -> some Component {
        layout.makeBody(spacing: spacing, alignment: alignment) {
            let components = [configuration.icon, configuration.title]
            if isReversal {
                components.reversed()
            } else {
                components
            }
        }
    }
}

public extension LabelStyle where Self == TitleAndIconLabelStyle {
    static var titleAndIcon: TitleAndIconLabelStyle {
        titleAndIcon(layout: .horizontal, alignment: .center, isReversal: false, spacing: 5)
    }

    static func titleAndIcon(layout: TitleAndIconLabelStyle.Layout, alignment: TitleAndIconLabelStyle.Alignment, isReversal: Bool, spacing: CGFloat) -> TitleAndIconLabelStyle {
        TitleAndIconLabelStyle(layout: layout, alignment: alignment, isReversal: isReversal, spacing: spacing)
    }
}

public extension LabelStyle where Self == TitleOnlyLabelStyle {
    static var titleOnly: TitleOnlyLabelStyle {
        TitleOnlyLabelStyle()
    }
}

public extension Label {
    struct StyleConfiguration {
        public let title: any Component
        public let icon: any Component
    }
}

public struct LabelStyleEnvironmentKey: EnvironmentKey {
    public static var defaultValue: any LabelStyle { .automatic }
}

public extension EnvironmentValues {
    var labelStyle: any LabelStyle {
        get {
            self[LabelStyleEnvironmentKey.self]
        } set {
            self[LabelStyleEnvironmentKey.self] = newValue
        }
    }
}

public extension Component {
    func labelStyle(_ style: any LabelStyle) -> EnvironmentComponent<any LabelStyle, Self> {
        environment(\.labelStyle, value: style)
    }
}

public struct Label: ComponentBuilder {
    @Environment(\.labelStyle)
    var labelStyle

    let title: any Component
    let icon: any Component

    public init(title: () -> any Component, icon: () -> any Component) {
        self.title = title()
        self.icon = icon()
    }

    public init(_ titleString: String, systemImage name: String, withConfiguration configuration: UIImage.Configuration? = nil) {
        self.init {
            Text(titleString)
        } icon: {
            Image(systemName: name, withConfiguration: configuration)
        }
    }

    public init(_ titleString: String, image name: String) {
        self.init {
            Text(titleString)
        } icon: {
            Image(name)
        }
    }

    public func build() -> some Component {
        labelStyle.makeBody(configuration: StyleConfiguration(title: title,
                                                              icon: icon))
            .eraseToAnyComponent()
    }
}

struct LabelBackground: Component {
    @Environment(\.foregroundColor)
    var foregroundColor

    let content: any Component
    let cornerRadius: CGFloat
    let inset: UIEdgeInsets

    init(content: any Component, cornerRadius: CGFloat = 10, inset: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)) {
        self.content = content
        self.cornerRadius = cornerRadius
        self.inset = inset
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let contentRenderNode = content
            .eraseToAnyComponent()
            .inset(inset)
            .backgroundColor(foregroundColor?.withAlphaComponent(0.1))
            .cornerRadius(10)
            .cornerCurve(.continuous)
            .layout(constraint)
        return contentRenderNode
    }
}

struct LabelBackgroundStyle {
    let color: UIColor
    let inset: UIEdgeInsets

    static func background(color: UIColor, edgeInsets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)) -> Self { .init(color: color, inset: edgeInsets) }
}

extension Component {
    func labelBackground(_ cornerRadius: CGFloat = 10, inset: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)) -> some Component {
        LabelBackground(content: self, cornerRadius: cornerRadius, inset: inset)
    }
}
