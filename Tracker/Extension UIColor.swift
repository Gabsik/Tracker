
import Foundation
import UIKit

extension UIColor {
    static var blueCastom: UIColor {
        return UIColor(named: "Blue") ?? UIColor.systemBlue
    }
    static var blackCastom: UIColor {
        return UIColor(named: "Black[day]") ?? UIColor.black
    }
    static var background: UIColor {
        return UIColor(named: "Background[day]") ?? UIColor.lightGray
    }
    static var redCastom: UIColor {
        return UIColor(named: "Red") ?? UIColor.red
    }
    static var grayCastom: UIColor {
        return UIColor(named: "Gray") ?? UIColor.gray
    }
}
