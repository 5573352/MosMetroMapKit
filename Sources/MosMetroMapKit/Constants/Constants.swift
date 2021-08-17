//
//  Constants.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 04.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit
import FloatingPanel

enum Constants {
      
    static var isDarkModeEnabled: Bool {
        if let theme = UserDefaults.standard.object(forKey: "AppApereance") as? String {
            if #available(iOS 13.0, *) {
                if theme == "dark" {
                    return true
                } else if theme == "light" {
                    return false
                } else {
                    return false
                }
            }
        } else {
            if #available(iOS 12.0, *) {
                switch UIScreen.main.traitCollection.userInterfaceStyle {
                case .dark:
                    return true
                case .light:
                    return false
                case .unspecified:
                    return false
                @unknown default:
                    fatalError()
                }
            } else {
                return false
            }
        }
        return false
    }
}

class MetroSearchBar: UISearchBar { }
class CitySearchBar : UISearchBar { }
