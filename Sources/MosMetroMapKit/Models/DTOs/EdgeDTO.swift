//
//  EdgeDTO.swift
//
//  Created by Павел Кузин on 12.04.2021.
//

import Foundation
import SwiftyJSON

class EdgeDTO {
    
    var id: Int = 0
    var from: StationDTO?
    var to: StationDTO?
    var weight: Double = 0.0
    var isFuture: Bool = false
    var svg: String = ""
    
    static func primaryKey() -> String? {
        return "id"
    }
    
    func map(_ data: JSON, stations: [Int: StationDTO]) {
        if let stationFromID = data["stationFromId"].int,
           let stationToID   = data["stationToId"].int,
           let from          = stations[stationFromID],
           let to            = stations[stationToID] {
            
            self.from     = from
            self.to       = to
            self.id       = data["id"].intValue
            self.weight   = data["pathLength"].doubleValue
            self.isFuture = data["perspective"].boolValue
            self.svg      = data["svg"].stringValue
        }
    }
    
    func mapReversed(_ data: JSON, stations: [Int: StationDTO]) {
        if let stationFromID = data["stationFromId"].int,
           let stationToID   = data["stationToId"].int,
           let from          = stations[stationFromID],
           let to            = stations[stationToID] {
            self.from     = to
            self.to       = from
            self.id       = data["id"].intValue + 1000
            self.weight   = data["pathLength"].doubleValue
            self.isFuture = data["perspective"].boolValue
            self.svg      = data["svg"].stringValue
        }
    }
}
