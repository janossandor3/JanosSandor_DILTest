import UIKit

extension UIDevice {
  static var isPhone: Bool { current.userInterfaceIdiom == .phone }
}
