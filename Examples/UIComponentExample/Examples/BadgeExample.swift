//  Created by Luke Zhao on 11/15/21.

import UIComponent
import UIKit

class BadgeViewController: ComponentViewController {
    override var component: any Component {
        VStack {
            Text("Badges", font: .boldSystemFont(ofSize: 20)).id("label3")
            VStack(spacing: 10) {
                Text("Badges custom offset")
                Flow(spacing: 10) {
                    Box().badge(NumberBadge(5), offset: CGPoint(x: 8, y: -8))
                    Box().badge(NumberBadge(12), offset: CGPoint(x: 8, y: -8))
                    Box().badge(NumberBadge("99+"), offset: CGPoint(x: 8, y: -8))
                    Box().badge(NumberBadge.redDot(), offset: CGPoint(x: -5, y: 5))
                    Space(width: 40, height: 40).badge(BannerBadge("New"), horizontalAlignment: .stretch, offset: CGPoint(x: 0, y: 2)).styleColor(.systemBlue).clipsToBounds(true)
                    Space(width: 40, height: 40).badge(BannerBadge("New"), verticalAlignment: .end, horizontalAlignment: .stretch, offset: CGPoint(x: 0, y: -2))
                        .styleColor(.systemBlue)
                        .clipsToBounds(true)
                }
                Text("Badges position")
                VStack(spacing: 10) {
                    for v in Badge.Alignment.allCases {
                        HStack(spacing: 10) {
                            for h in Badge.Alignment.allCases {
                                Box().badge(NumberBadge.redDot(), verticalAlignment: v, horizontalAlignment: h)
                            }
                        }
                    }
                }
            }
            .inset(10).styleColor(.systemGroupedBackground).id("badges")
        }
        .inset(20)
    }
}

struct NumberBadge: ComponentBuilder {
    let text: String
    let isRoundStyle: Bool
    func build() -> some Component {
        Text(
            text,
            font: .systemFont(ofSize: 12)
        )
        .size(
            width: text.isEmpty ? .absolute(8) : text.count <= 2 ? .absolute(16) : .fit,
            height: text.isEmpty ? .absolute(8) : .absolute(16)
        )
        .adjustsFontSizeToFitWidth(true)
        .textColor(.white)
        .textAlignment(.center)
        .inset(
            h: text.isEmpty ? 0 : text.count <= 2 ? 2 : 5,
            v: text.isEmpty ? 0 : 2
        )
        .view()
        .backgroundColor(.systemRed)
        .update {
            $0.layer.cornerCurve = .continuous
            $0.layer.cornerRadius = isRoundStyle ? min($0.frame.width, $0.frame.height) / 2 : 0
        }
        .clipsToBounds(true)
    }

    static func redDot() -> Self {
        return NumberBadge("")
    }

    init(_ text: String, isRoundStyle: Bool = true) {
        self.text = text
        self.isRoundStyle = isRoundStyle
    }

    init(_ int: Int, isRoundStyle: Bool = true) {
        self.text = "\(int)"
        self.isRoundStyle = isRoundStyle
    }

}

struct BannerBadge: ComponentBuilder {
    let text: String
    func build() -> some Component {
        Text(text, font: .systemFont(ofSize: 11)).textAlignment(.center).textColor(.white).backgroundColor(.systemRed).adjustsFontSizeToFitWidth(true).size(height: .absolute(15))
            .inset(h: 2)
    }

    init(_ text: String) {
        self.text = text
    }
}
