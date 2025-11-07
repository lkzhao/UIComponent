//  Created by Huy on 11/5/25.

import Foundation
import UIKit

extension NSAttributedString {

    // Returns the ascender of an attributed string.
    // It is the ascender of the first character of an attributed string.
    // It also includes the line height if specified in paragraph style.
    public var ascender: CGFloat {
        guard let font = self.attribute(.font, at: 0, effectiveRange: nil) as? UIFont else {
            return 0
        }

        guard let paragraphStyle = self.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle else {
            return font.ascender;
        }

        var lineHeight = max(font.lineHeight, paragraphStyle.minimumLineHeight)
        if paragraphStyle.maximumLineHeight > 0 {
            lineHeight = min(lineHeight, paragraphStyle.maximumLineHeight)
        }
        return lineHeight + font.descender;
    }

    // Returns the descender of an attributed string.
    // It is the descender of the last character's font.
    public var descender: CGFloat {
        guard let font = self.attribute(.font, at: self.length - 1, effectiveRange: nil) as? UIFont else {
            return 0
        }
        return font.descender;
    }
}
