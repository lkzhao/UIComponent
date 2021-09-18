//  Created by Luke Zhao on 8/23/20.

import UIComponent
import UIKit

extension UIView {
  public var parentViewController: UIViewController? {
    var responder: UIResponder? = self
    while responder is UIView {
      responder = responder!.next
    }
    return responder as? UIViewController
  }

  public func present(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
    parentViewController?.present(viewController, animated: true, completion: completion)
  }
}

extension UIColor {
  static let systemColors: [UIColor] = [
    .systemRed, .systemBlue, .systemPink, .systemTeal, .systemGray, .systemFill, .systemGreen, .systemGreen, .systemYellow, .systemPurple, .systemOrange,
  ]
  static func randomSystemColor() -> UIColor {
    systemColors.randomElement()!
  }
}

extension CGRect {
  var center: CGPoint {
    return CGPoint(x: midX, y: midY)
  }

  init(center: CGPoint, size: CGSize) {
    self.init(origin: CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2), size: size)
  }
}

extension Array {
  /*
   This method split array of elements into chunks of a size  specify

   Take a look at this example:
   ```
   let array = [1,2,3,4,5,6,7]
   array.chuncked(by: 3) // [[1,2,3], [4,5,6], [7]]
   ```

   - parameter chunkSize: Subarray size.
   */
  public func chunked(by chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: self.count, by: chunkSize)
      .map {
        Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
      }
  }
}

func randomInt(minNum: UInt32, maxNum: UInt32) -> Int {
  Int(arc4random_uniform(maxNum - minNum) + minNum)
}

typealias WebImageSize = (width: Int, height: Int)

func randomWebImage(require size: WebImageSize = (width: 1000, height: 1000)) -> URL {
  let url = "https://picsum.photos/\(size.width)/\(size.height)?random=\(UUID().uuidString)"
  return URL(string: url)!
}
