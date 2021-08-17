//
//  StationDTO.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 12.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import Foundation
import SwiftyJSON
import Localize_Swift

class ExitDTO {
    var latitude   : Double = 0.0
    var longitude  : Double = 0.0
    var name_ru    : String = "Выход"
    var name_en    : String = "Exit"
    var exitNumber : Int = 1
    var buses      = [String]()
    var trams      = [String]()
    var trolleys   = [String]()
    
    func map(_ data: JSON) {
        self.latitude   = data["location"]["lat"].doubleValue
        self.longitude  = data["location"]["lon"].doubleValue
        self.name_ru    = data["title"]["ru"].stringValue
        self.name_en    = data["title"]["en"].string ?? "Exit"
        self.exitNumber = data["exitNumber"].intValue
        
        if let buses = data["bus"].string {
            let deletedSpaces = buses.replacingOccurrences(of: " ", with: "")
            let busesArr = deletedSpaces.components(separatedBy: ",")
            self.buses.append(contentsOf: busesArr)
        }
        
        if let trolleys = data["trolleybus"].string {
            let deletedSpaces = trolleys.replacingOccurrences(of: " ", with: "")
            let trolleysArr = deletedSpaces.components(separatedBy: ",")
            self.trolleys.append(contentsOf: trolleysArr)
        }
        
        if let trams = data["tram"].string {
            let deletedSpaces = trams.replacingOccurrences(of: " ", with: "")
            let tramsArr = deletedSpaces.components(separatedBy: ",")
            self.trams.append(contentsOf: tramsArr)
        }
    }
}

class WorktimeDTO {
    var open  : String = "05:30"
    var close : String = "01:00"
    
    func map(_ data: JSON) {
        self.open  = data["open"].string ?? self.open
        self.close = data["close"].string ?? self.close
    }
}

class TrainsScheduleDTO {
    var toID = 0
    var schedules = [SchedulePartDTO]()
}

class SchedulePartDTO {
    var first: String = ""
    var last: String = ""
    var dayType = "EVEN"
    var isWeekend = false
    
    func map(_ data: JSON) {
        self.first     = data["first"].stringValue
        self.last      = data["last"].stringValue
        self.dayType   = data["dayType"].stringValue
        self.isWeekend = data["weekend"].boolValue
    }
}

class StationGraphics {
    var mainSVG: String = ""
    var tapGrid: RectangleDTO?
    var text: RectangleDTO?
    
    func map(_ json: JSON) {
        self.mainSVG =  json["stationSvg"]["svg"].stringValue
        let tapGrid = RectangleDTO()
        tapGrid.x = json["tapSvg"]["x"].doubleValue
        tapGrid.y = json["tapSvg"]["y"].doubleValue
        tapGrid.w = json["tapSvg"]["w"].doubleValue
        tapGrid.h = json["tapSvg"]["h"].doubleValue
        self.tapGrid = tapGrid
        let text = RectangleDTO()
        text.x = json["textSvg"]["x"].doubleValue
        text.y = json["textSvg"]["y"].doubleValue
        text.w = json["textSvg"]["w"].doubleValue
        text.h = json["textSvg"]["h"].doubleValue
        self.text = text
    }
}

class RectangleDTO {
    var x: Double = 0
    var y: Double = 0
    var w: Double = 0
    var h: Double = 0
}

public class StationDTO {
    
    // MARK: Stored properties
    var id        : Int = 0
    var name_ru   : String = ""
    var name_en   : String = "Station"
    var isFuture  : Bool = false
    var latitude  : Double = 0.0
    var longitude : Double = 0.0
    var lineOrder : Int = 0
    var x         : Double = 0.0
    var y         : Double = 0.0
    var buses     : String = ""
    var trams     : String = ""
    var trolleys  : String = ""
    var isTransitionStation: Bool = false
    var enterTime = 0
    var exitTime  = 0
    var isMCD     : Bool = false
    var isMCC     : Bool = false
    var isOutside : Bool = false
    var trainsSchdule = [TrainsScheduleDTO]()
    var services  = [String]()
    var graphics  : StationGraphics?
    
    // MARK: Linked objects and Lists
    var line        : LineDTO?
    var worktime    = [WorktimeDTO]()
    var exits       = [ExitDTO]()
    var transitions = [StationDTO]()
    
    // MARK: Primary key
    static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: Indexed properties
    static func indexedProperties() -> [String] {
        return ["name_ru","name_en"]
    }
    
    // MARK: Get only properties
    var name: String {
        return Localize.currentLanguage() == "ru" ? self.name_ru : self.name_en
    }
    
    func map(_ data: JSON, lines: [LineDTO]) {
        self.id = data["id"].intValue
        self.name_ru = data["name"]["ru"].stringValue
        self.name_en = data["name"]["en"].stringValue
        self.isFuture = data["perspective"].boolValue
        self.latitude = data["location"]["lat"].doubleValue
        self.longitude = data["location"]["lon"].doubleValue
        //self.x = data["svg_station_center"]["x"].doubleValue
        //self.y = data["svg_station_center"]["y"].doubleValue
        self.lineOrder = data["ordering"].intValue
        self.enterTime = data["enterTime"].int ?? 0
        self.exitTime = data["exitTime"].int ?? 0
        self.isMCD = data["mcd"].bool ?? false
        self.isMCC = data["mcc"].bool ?? false
        self.isOutside = data["outside"].bool ?? false
        self.enterTime = data["enterTime"].intValue
        self.exitTime = data["exitTime"].intValue
        if let servicesArray = data["services"].array {
            for item in servicesArray {
                self.services.append(item.stringValue)
            }
        }
        
        if let worktimeArr = data["workTime"].array {
            let array: [WorktimeDTO] = worktimeArr.map {
                let worktime = WorktimeDTO()
                worktime.map($0)
                return worktime
            }
            self.worktime.append(contentsOf: array)
        }
        
        let svg = StationGraphics()
        svg.map(data)
        self.graphics = svg
        self.x = data["stationSvg"]["x"].doubleValue
        self.y = data["stationSvg"]["y"].doubleValue
        if let line = lines.filter({ $0.id == data["lineId"].intValue }).first {
            self.line = line
        }
        if !data["exits"].isEmpty {
            for (key,subJson) in data["exits"] {
                let exitDTO = ExitDTO()
                exitDTO.map(subJson)
                self.exits.append(exitDTO)
            }
        }
        
        if !data["scheduleTrains"].isEmpty {
            for (key,subjson) in data["scheduleTrains"] {
                if let toID = Int(key), let partsArray = subjson.array {
                    let trainsSchedule = TrainsScheduleDTO()
                    trainsSchedule.toID = toID
                    partsArray.forEach {
                        let part = SchedulePartDTO()
                        part.map($0)
                        trainsSchedule.schedules.append(part)
                    }
                    self.trainsSchdule.append(trainsSchedule)
                }
            }
        }
    }
}
