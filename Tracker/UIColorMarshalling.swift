
import UIKit


enum UIColorMarshalling {
    static func serialize(_ color: UIColor) -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return "\(red),\(green),\(blue),\(alpha)"
    }
    
    static func deserialize(_ string: String) -> UIColor {
        let comps = string.split(separator: ",").compactMap { Double($0) }
        guard comps.count == 4 else { return .black }
        return UIColor(red: CGFloat(comps[0]), green: CGFloat(comps[1]), blue: CGFloat(comps[2]), alpha: CGFloat(comps[3]))
    }
}
