
import Foundation
import UIKit

extension UIColor {
    static var blueCastom: UIColor {
        return UIColor(named: "Blue") ?? UIColor.systemBlue
    }
    static var blackCastom: UIColor {
        return UIColor(named: "Black[day]") ?? UIColor.black
    }
}
