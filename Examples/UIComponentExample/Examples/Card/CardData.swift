//  Created by Luke Zhao on 6/15/21.

import Foundation

struct CardData {
    let id: String = "card-\(UUID().uuidString)"
    let title: String
    let subtitle: String

    static let testCards: [CardData] = (1..<7)
        .map {
            CardData(title: "Item \($0)", subtitle: "Description \($0)")
        }
}
