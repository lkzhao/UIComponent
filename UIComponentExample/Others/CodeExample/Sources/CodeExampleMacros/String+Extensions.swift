//  Created by Luke Zhao on 11/4/25.

import Foundation

public extension String {
    func trimLeadingWhitespacesBasedOnFirstLine() -> String {
        let lines = self.trimmingCharacters(in: .newlines).split(separator: "\n", omittingEmptySubsequences: false)
        guard let firstLine = lines.first else {
            return self
        }
        let leadingWhitespaceCount = firstLine.prefix { $0.isWhitespace }.count
        let trimmedLines = lines.map { line in
            let count = line.prefix { $0.isWhitespace }.count
            return line.dropFirst(min(count, leadingWhitespaceCount))
        }
        return trimmedLines.joined(separator: "\n")
    }
}
