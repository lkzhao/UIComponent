import UIKit

extension Component {
    /// Centers the component within the parent's boundary
    /// - Returns: A `ZStack` component containing the centered component with `.fill` size strategy applied.
    public func centered() -> some Component {
        ZStack {
            self
        }.fill()
    }
}
