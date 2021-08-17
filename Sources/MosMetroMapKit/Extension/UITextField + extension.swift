//
//  UITextField + extension.swift
//  MosmetroNew
//
//  Created by Владимир Камнев on 12.07.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit

extension UITextField {
    /// Метод для создания кнопок для тулбара
    /// - Parameters:
    ///   - titles: тексты внутри кнопок
    ///   - action: обработчик действия
    /// - Returns: кнопки для тулбара
    public func getToolbarItems(titles: [String], target: Any, action: Selector) -> [UIBarButtonItem] {
        var buttons = [UIBarButtonItem]()
        for title in titles {
            if #available(iOS 14.0, *) {
                let flexibleButton  = UIBarButtonItem(systemItem: .flexibleSpace)
                buttons.append(flexibleButton)
            }
            let divider             = CGFloat(titles.count)
            let button              = UIButton.init(type: .custom)
            button.frame            = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / divider - 6, height: 35)
            button.titleLabel?.font = .Body_15_Regular
            button.backgroundColor  = .toolBarAction
            button.setTitle(title, for: .normal)
            button.roundCorners(.all, radius: 6)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(target, action: action, for: .touchUpInside)
            
            buttons.append(UIBarButtonItem(customView: button))
        }
        
        if #available(iOS 14.0, *) {
            let flexibleButton = UIBarButtonItem(systemItem: .flexibleSpace)
            buttons.append(flexibleButton)
        }
        
        return buttons
    }
    
    public func setPaymentToolbar(target: Any, with action: Selector)  {
        let items     = getToolbarItems(titles: ["100 ₽", "300 ₽", "500 ₽"], target: target, action: action)
        let toolbar   = UIToolbar()
        toolbar.items = items
        toolbar.sizeToFit()
        toolbar.barTintColor         = .toolBarBack 
        self.inputAccessoryView = toolbar
    }
}
