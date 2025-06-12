
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

extension UIColor {
    static let trackersPalette: [UIColor] = [
        UIColor(hex: "#FD4C49"), // Color 1
        UIColor(hex: "#FF881E"), // Color 2
        UIColor(hex: "#007BFA"), // Color 3
        UIColor(hex: "#6E44FE"), // Color 4
        UIColor(hex: "#33CF69"), // Color 5
        UIColor(hex: "#E66DD4"), // Color 6
        UIColor(hex: "#F9D4D4"), // Color 7
        UIColor(hex: "#34A7FE"), // Color 8
        UIColor(hex: "#46E69D"), // Color 9
        UIColor(hex: "#35347C"), // Color 10
        UIColor(hex: "#FF674D"), // Color 11
        UIColor(hex: "#FF99CC"), // Color 12
        UIColor(hex: "#F6C48B"), // Color 13
        UIColor(hex: "#7994F5"), // Color 14
        UIColor(hex: "#832CF1"), // Color 15
        UIColor(hex: "#AD56DA"), // Color 16
        UIColor(hex: "#8E72E6"), // Color 17
        UIColor(hex: "#2FD058")  // Color 18
    ]

    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }

        var rgb: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

