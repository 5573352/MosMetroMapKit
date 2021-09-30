//
//  NewColor.swift
//
//  Created by Владимир Камнев on 15.06.2021.
//

import UIKit

extension UIColor {
    
    public class var main: UIColor {
        return UIColor(named: "NewMain")         ?? UIColor.systemRed
    }
    
    public class var baseIOS: UIColor {
        return UIColor(named: "BaseIOS")         ?? UIColor.white
    }
    
    public class var contentIOS: UIColor {
        return UIColor(named: "card_background") ?? UIColor.white
    }
    
    public class var textPrimary: UIColor {
        return UIColor(named: "TextPrimary")     ?? UIColor.black
    }
    
    public class var textSecondary: UIColor {
        return UIColor(named: "TextSecondary")   ?? UIColor.gray
    }
    
    public class var buttonSecondary: UIColor {
        return UIColor(named: "ButtonSecondary") ?? UIColor.gray
    }
    
    public class var buttonTertiary: UIColor {
        return UIColor(named: "ButtonTertiary") ?? UIColor.gray
    }
    
    public class var textfield: UIColor {
        return UIColor(named: "NewTextfield")   ?? UIColor.white
    }
    
    public class var separator: UIColor {
        return UIColor(named: "NewSeparator")   ?? UIColor.white
    }
    
    public class var green: UIColor {
        return UIColor(named: "Green")          ?? UIColor.white
    }
    
    public class var red: UIColor {
        return UIColor(named: "Red")            ?? UIColor.systemRed
    }
    
    public class var iconTertiary: UIColor {
        return UIColor(named: "IconTertiary")   ?? UIColor.gray
    }
    
    public class var toolBarAction: UIColor {
        return UIColor(named: "ToolBarAction")  ?? UIColor.gray
    }
    
    public class var toolBarBack: UIColor {
        return UIColor(named: "ToolBarBack")    ?? UIColor.gray
    }
    
    public class var warning : UIColor {
        return UIColor(named: "Warning")    ?? UIColor.green
    }
    
    public class var information : UIColor {
        return UIColor(named: "Information")    ?? UIColor.green
    }
}
