//
//  EmergencyDTO.swift
//
//  Created by Павел Кузин on 12.04.2021.
//

import SwiftDate
import Foundation
import SwiftyJSON

class StationEmergencyDTO {
    var stationID = 0
    var title_ru  = ""
    var title_en  = ""
    var desc_ru   = ""
    var desc_en   = ""
    var status    = ""
    
    func map(_ data: JSON) {
        self.stationID = data["stationId"].intValue
        self.title_ru  = data["title"]["ru"].stringValue
        self.title_en  = data["title"]["en"].stringValue
        self.desc_ru   = data["description"]["ru"].stringValue
        self.desc_en   = data["description"]["en"].stringValue
        self.status    = data["status"].stringValue
    }
}

class ConnectionEmergencyDTO {
    var connectionID = 0
    var status       = ""
    var isTransition = false
    var redraw       = false
    
    func map(_ data: JSON) {
        if let connectionID = data["connectionId"].int {
            self.connectionID = connectionID
        }
        if let transitionID = data["transitionId"].int {
            self.connectionID = transitionID
        }
        self.status = data["status"].stringValue
        if let redraw = data["redraw"].bool {
            self.redraw = redraw
        }
    }
}

class AlternativeConnectionDTO {
    
    var id            : Int = 0
    var fromStationID : Int = 0
    var toStationID   : Int = 0
    var weight        : Double = 0.0
    var svg           : String = ""
    
    static func primaryKey() -> String? {
        return "id"
    }
    
    func mapAlternative(data: JSON) {
        if let stationFromID = data["stationFromId"].int,
           let stationToID   = data["stationToId"].int {
            self.fromStationID = stationFromID
            self.toStationID   = stationToID
            self.id            = 3000 + data["id"].intValue
            self.weight        = data["pathLength"].doubleValue
            self.svg           = data["svg"].stringValue
        }
    }
    
    func mapAlternativeReversed(data: JSON) {
       if let stationFromID = data["stationFromId"].int,
        let stationToID     = data["stationToId"].int {
            self.fromStationID = stationToID
            self.toStationID   = stationFromID
            self.id            = 4000 + data["id"].intValue
            self.weight        = data["pathLength"].doubleValue
            self.svg           = data["svg"].stringValue
        }
    }
}

public struct  EmergencyDTO {
    var id = 0
    var title_ru  : String = "default"
    var title_en  : String = "default"
    var desc_ru   : String = "no"
    var desc_en   : String = "no"
    var extraSVG  = "null"
    var startDate = Date()
    var endDate   = Date()
    var stations               = [StationEmergencyDTO]()
    var connections            = [ConnectionEmergencyDTO]()
    var alternativeConnections = [AlternativeConnectionDTO]()
    
    static func primaryKey() -> String? {
        return "id"
    }
    
    static func map(_ data: JSON) -> EmergencyDTO {
        var em = EmergencyDTO(
            id                     : data["id"].intValue,
            title_ru               : data["title"]["ru"].string ?? "default",
            title_en               : data["title"]["en"].string ?? "default",
            desc_ru                : data["description"]["ru"].string ?? "no",
            desc_en                : data["description"]["en"].string ?? "no",
            extraSVG               : data["extraSvg"].string ?? "null",
            startDate              : Date(),
            endDate                : Date(),
            stations               : [],
            connections            : [],
            alternativeConnections : []
        )
        if let startDate = data["startDate"].stringValue.toDate(),
           let endDate   = data["endDate"].stringValue.toDate() {
            let start = startDate.convertTo(region: Region(calendar: Calendars.gregorian, zone: Zones.europeMoscow, locale: Locales.russian)).date.addingTimeInterval(10800)
            let end = endDate.convertTo(region: Region(calendar: Calendars.gregorian, zone: Zones.europeMoscow, locale: Locales.russian)).date.addingTimeInterval(10800)
            em.startDate = start
            em.endDate = end
        }
        if let _stations = data["stations"].array {
            for station in _stations {
                let stationEmergencyDTO = StationEmergencyDTO()
                stationEmergencyDTO.map(station)
                em.stations.append(stationEmergencyDTO)
            }
        }
        if let _connections = data["connections"].array {
            for connectionData in _connections {
                let connectionEmergencyDTO = ConnectionEmergencyDTO()
                connectionEmergencyDTO.map(connectionData)
                em.connections.append(connectionEmergencyDTO)
            }
        }
        if let _transitions = data["transitions"].array {
            for transitionData in _transitions {
                let transitionEmergencyDTO = ConnectionEmergencyDTO()
                transitionEmergencyDTO.map(transitionData)
                transitionEmergencyDTO.isTransition = true
                em.connections.append(transitionEmergencyDTO)
            }
        }
        if let _alternativeConnections = data["alternativeConnections"].array {
            for alternativeData in _alternativeConnections {
                let connection = AlternativeConnectionDTO()
                connection.mapAlternative(data: alternativeData)
                if !alternativeData["closedBackward"].boolValue {
                    let reversedConnection = AlternativeConnectionDTO()
                    reversedConnection.mapAlternativeReversed(data: alternativeData)
                    em.alternativeConnections.append(reversedConnection)
                }
                em.alternativeConnections.append(connection)
            }
        }
        return em
    }
}
