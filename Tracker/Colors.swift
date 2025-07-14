
import UIKit


final class Colors {
    
    let viewBackgroundColor = UIColor.systemBackground
    
    var datePickerBackgroundColor: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? .background : .clear
        }
    }
    
    var navigationBarButtonColor: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? .white : .black
        }
    }
    var doneIconColor: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? .black : .white
        }
    }
    var tabelViewColor: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? .black : .white
        }
    }
}
