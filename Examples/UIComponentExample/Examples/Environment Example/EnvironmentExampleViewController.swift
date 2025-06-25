//  Created by y H on 2025/6/25.

import UIKit
import UIComponent

class EnvironmentExampleViewController: ComponentViewController {
    override var component: any Component {
        VStack(spacing: 10, alignItems: .stretch) {
            Text("Used")
            Label("Share", systemImage: "square.and.arrow.up.fill")
                .minSize(height: 44)
                .centered()
                .backgroundColor(.systemBlue)
                .roundedCorner()
            Label("Remove", systemImage: "trash.fill")
                .minSize(height: 44)
                .centered()
                .backgroundColor(.systemRed)
                .roundedCorner()
            
            HStack(spacing: 10, alignItems: .stretch) {
                HStack(spacing: 5, alignItems: .stretch) {
                    Label("Share", systemImage: "square.and.arrow.up.fill")
                        .centered()
                        .backgroundColor(.systemGreen)
                        .roundedCorner()
                        .labelStyle(.titleAndIcon(layout: .horizontal, alignment: .center, isReversal: false, spacing: 5))
                        .flex()
                    Label("Remove", systemImage: "trash.fill")
                        .centered()
                        .backgroundColor(.systemRed)
                        .roundedCorner()
                        .labelStyle(.titleAndIcon(layout: .horizontal, alignment: .center, isReversal: true, spacing: 5))
                        .flex()
                }
                .font(.systemFont(ofSize: 14, weight: .semibold))
                .flex(0.4)
                HStack(spacing: 5, alignItems: .stretch) {
                    Label("Share", systemImage: "square.and.arrow.up.fill")
                        .centered()
                        .backgroundColor(.systemGreen)
                        .roundedCorner()
                        .labelStyle(.titleAndIcon(layout: .vertical, alignment: .center, isReversal: false, spacing: 5))
                        .flex()
                    Label("Remove", systemImage: "trash.fill")
                        .centered()
                        .backgroundColor(.systemRed)
                        .roundedCorner()
                        .labelStyle(.titleAndIcon(layout: .vertical, alignment: .center, isReversal: true, spacing: 5))
                        .flex()
                }
                .font(.systemFont(ofSize: 12))
                .flex(0.6)
            }
            .size(height: 44)
            let fontSizes: [CGFloat] = [12,14,16,18,20,22,24,26,28,30]
            VStack(spacing: 10) {
                HStack(spacing: 5) {
                    let fonts: [UIFont] = fontSizes.map { .systemFont(ofSize: $0, weight: .thin) }
                    for font in fonts {
                        Image(systemName: "alarm")
                            .font(font)
                    }
                }
                HStack(spacing: 5) {
                    let fonts: [UIFont] = fontSizes.map { .systemFont(ofSize: $0, weight: .regular) }
                    for font in fonts {
                        Image(systemName: "alarm")
                            .font(font)
                    }
                }
                HStack(spacing: 5) {
                    let fonts: [UIFont] = fontSizes.map { .systemFont(ofSize: $0, weight: .semibold) }
                    for font in fonts {
                        Image(systemName: "alarm")
                            .font(font)
                    }
                }
            }
            .foregroundColor(.systemIndigo)
        }
        .foregroundColor(.white)
        .font(.systemFont(ofSize: 16, weight: .semibold))
        .inset(20)
    }
}
