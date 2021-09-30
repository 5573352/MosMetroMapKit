//
//  ColorConstants.swift
//
//  Created by Владимир Камнев on 09.06.2021.
//

import UIKit

extension UIColor {
    
    public class var mainColor: UIColor {
        return UIColor(named: "main") ?? UIColor.red
    }
    
    public class var MKBase: UIColor {
        return UIColor(named: "Base") ?? UIColor.white
    }
    
    public class var overlay: UIColor {
        return UIColor(named: "overlay") ?? UIColor.white
    }
    
    public class var text: UIColor {
        return UIColor(named: "text") ?? UIColor.black
    }
    
    public class var secondaryButtonColor: UIColor {
        return UIColor(named: "Secondary_button") ?? UIColor.red
    }
    
    public class var grey: UIColor {
        return UIColor(named: "grey") ?? UIColor.gray
    }
    
    public class var grey2: UIColor {
        return UIColor(named: "grey2") ?? UIColor.gray
    }
    
    public class var navigationBar: UIColor {
        return UIColor(named: "navigationBar") ?? UIColor.green
    }
    
    public class var metroBookmark: UIColor {
        return UIColor(named: "bookmark") ?? UIColor.orange
    }
    
    public class var MKOpacityButton: UIColor {
        return UIColor(named: "opacityButton") ?? UIColor.grey
    }
    
    public class var MKTextfield: UIColor {
        return UIColor(named: "textfield") ?? UIColor.grey
    }
    
    public class var cardBackground: UIColor {
        return UIColor(named: "card_background") ?? .white
    }
    
    public class var metroLink: UIColor {
        return UIColor(named: "link") ?? UIColor.green
    }
    
    /// Use this color with elements describing station closing
    public class var metroClosing: UIColor {
        return UIColor(named: "closing") ?? UIColor.red
    }
    
    /// Use it with time signs – such as worktime, schedule etc
    public class var metroGreen: UIColor {
        return UIColor(named: "metro_green") ?? UIColor.green
    }
    
    /// Use it with time signs – such as worktime, schedule etc
    public class var metroRed: UIColor {
        return UIColor(named: "metro_red") ?? UIColor.red
    }
    
    /// Use it with time signs – such as worktime, schedule, attention etc
    public class var metroOrange: UIColor {
        return UIColor(named: "metro_orange") ?? UIColor.orange
    }
    
    public class var invertedText: UIColor {
        return UIColor(named: "InvertedTextColor") ?? UIColor.black
    }
    
    public class var mapBackground: UIColor {
        return UIColor(named: "mapBackground") ?? UIColor.white
    }
    
    public class var parking : UIColor {
        return UIColor(named: "Parking") ?? UIColor.green
    }
}
