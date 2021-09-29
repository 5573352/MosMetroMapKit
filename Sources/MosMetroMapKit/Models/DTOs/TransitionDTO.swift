//
//  TransitionDTO.swift
//
//  Created by Павел Кузин on 12.04.2021.
//

import Foundation
import SwiftyJSON

class TransitionPartDTO {
    var prevStationID: Int = 0
    var types = [String]()
    
    func map(_ data: JSON) {
        self.prevStationID = data["stationPrevId"].intValue
        if let types = data["types"].array {
            types.forEach { self.types.append($0.stringValue) }
        }
    }
}

class TransitionDTO: EdgeDTO {
    
    var wagons = [TransitionPartDTO]()
    var pathVideoURL: String = "no"
    var isGround: Bool = false
    
    override func map(_ data: JSON, stations: [Int: StationDTO]) {
        if let stationFromID = data["stationFromId"].int,
           let stationToID   = data["stationToId"].int,
           let from          = stations[stationFromID],
           let to            = stations[stationToID] {
            self.svg          = data["svg"].stringValue
            self.from         = from
            self.to           = to
            self.id           = data["id"].intValue
            self.weight       = data["pathLength"].doubleValue
            self.isFuture     = data["perspective"].boolValue
            self.isGround     = data["ground"].bool ?? false
            self.pathVideoURL = data["videoTo"].string ?? "no"
            
            if let wagons = data["wagons"].array {
                let filtered = wagons.filter { item in
                    guard
                        let toId = item["stationToId"].int,
                        let to   = self.to?.id
                    else { return false }
                    if toId == to { return true }
                    return false
                }
                for wagon in filtered {
                    let transitionPart = TransitionPartDTO()
                    transitionPart.map(wagon)
                    self.wagons.append(transitionPart)
                }
            }
            
            if self.from != nil && self.to != nil {
                from.transitions.append(to)
                from.isTransitionStation = true
                to.isTransitionStation = true
            }
        }
    }
    
    override func mapReversed(_ data: JSON, stations: [Int: StationDTO]) {
         if let stationFromID = data["stationFromId"].int, let stationToID = data["stationToId"].int, let from = stations[stationFromID], let to = stations[stationToID] {
            self.from         = to
            self.to           = from
            self.svg          = data["svg"].stringValue
            self.id           = data["id"].intValue + 1000
            self.weight       = data["pathLength"].doubleValue
            self.isFuture     = data["perspective"].boolValue
            self.isGround     = data["ground"].bool ?? false
            self.pathVideoURL = data["videoFrom"].string ?? "no"
             
            if let wagons = data["wagons"].array {
                let filtered = wagons.filter { item in
                    guard
                        let toId = item["stationToId"].int,
                        let _to = self.to?.id
                    else { return false }
                    if toId == _to { return true }
                    return false
                }
                for wagon in filtered {
                    let transitionPart = TransitionPartDTO()
                    transitionPart.map(wagon)
                    self.wagons.append(transitionPart)
                }
            }
            
            if self.from != nil && self.to != nil {
                to.transitions.append(from)
                from.isTransitionStation = true
                to.isTransitionStation = true
            }
        }
    }
}
