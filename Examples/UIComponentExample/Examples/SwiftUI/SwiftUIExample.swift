//  Created by Luke Zhao on 5/12/25.

import Foundation
import SwiftUI
import UIComponent

class SwiftUIExampleViewController: ComponentViewController {
    override var component: any Component {
        VStack {
            // UIComponent Text
            Text("SwiftUI", font: .boldSystemFont(ofSize: 20))

            SwiftUIComponent {
                // Swift UI Text
                SwiftUI.Text("Hello World! \(Image(systemName: "arrow.left")) (SwiftUI Text)")
            }

            // Custom SwiftUI View
            SwiftUIComponent(MyGradient()).size(width: .fill, height: 200)

            // Use SwiftUI directly
            SwiftUI.VStack {
                SwiftUI.Text("Hello Again!")
                SwiftUI.Text("Hello Again & Again!").blur(radius: 5)
            }
        }
        .inset(20)
    }
}

struct MyGradient: View {
    var body: some View {
        MeshGradient(width: 3, height: 3, points: [
            .init(0, 0), .init(0.5, 0), .init(1, 0),
            .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
            .init(0, 1), .init(0.5, 1), .init(1, 1)
        ], colors: [
            .red, .purple, .indigo,
            .orange, .white, .blue,
            .yellow, .green, .mint
        ])
    }
}
