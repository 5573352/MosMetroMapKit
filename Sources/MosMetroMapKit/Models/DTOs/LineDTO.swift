//
//  LineDTO.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 12.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit
import SwiftyJSON
import Localize_Swift

class LineDTO {
    // MARK: Stored Properties
    var id: Int = 0
    var name_ru: String = ""
    var name_en: String = ""
    var color: String = ""
    var order: Int = 0
    var firstStationID: Int = 0
    var lastStationID: Int = 0
    var firstStationPrompt_ru: String = ""
    var firstStationPrompt_en: String = ""
    var lastStationPrompt_ru: String = ""
    var lastStationPrompt_en: String = ""
    var neighbourLinesIDs = [Int]()
    
    static func primaryKey() -> String? {
           return "id"
       }
    
    // MARK: Get only properties
    
    var name: String {
        return Localize.currentLanguage() == "ru" ? self.name_ru : self.name_en
    }
    
    var originalImage: UIImage {
        return UIImage(named: "line_\(self.order)") ?? UIImage()
    }
    
    var invertedImage: UIImage {
        return UIImage(named: "line_\(self.order) inverted") ?? UIImage()
    }
    
    var uiColor: UIColor {
        return UIColor.hexStringToUIColor(hex: self.color)
    }
    
    var firstStationPrompt: String? {
        if Localize.currentLanguage() == "ru" {
            return self.firstStationPrompt_ru == "" ? nil : self.firstStationPrompt_ru
        } else {
            return self.firstStationPrompt_en == "" ? nil : self.firstStationPrompt_en
        }
    }
    
    var lastStationPrompt: String? {
        if Localize.currentLanguage() == "ru" {
            return self.lastStationPrompt_ru == "" ? nil : self.lastStationPrompt_ru
        } else {
            return self.lastStationPrompt_en == "" ? nil : self.lastStationPrompt_en
        }
    }
    
    func map(_ data: JSON) {
        self.id = data["id"].intValue
        self.name_ru = data["name"]["ru"].stringValue
        self.name_en = data["name"]["en"].string ?? data["name"]["ru"].stringValue
        self.color = data["color"].stringValue
        self.order = data["ordering"].intValue
        self.firstStationID = data["stationStartId"].intValue
        self.lastStationID = data["stationEndId"].intValue
        self.firstStationPrompt_ru = data["textStart"]["ru"].stringValue
        self.firstStationPrompt_en = data["textStart"]["en"].stringValue
        self.lastStationPrompt_ru = data["textEnd"]["ru"].stringValue
        self.lastStationPrompt_en = data["textEnd"]["en"].stringValue
        
        if let neighbourLines = data["neighboringLines"].array {
            for lineID in neighbourLines {
                //lineID.intValue
                self.neighbourLinesIDs.append(lineID.intValue)
            }
        }
    }
}

