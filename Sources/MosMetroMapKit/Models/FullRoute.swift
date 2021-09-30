//
//  Route.swift
//
//  Created by Сеня Римиханов on 25.05.2020.
//

import Foundation

enum Wagons : String {
    case all       = "ALL"
    case end       = "END"
    case first     = "FIRST"
    case center    = "CENTER"
    case nearEnd   = "NEAR_END"
    case nearFirst = "NEAR_FIRST"
}

enum Validation {
    case exitPayment  (Int?)
    case entryPayment (Int?)
}

struct RouteMetadata {
    let totalTime : Double
    let transfers : Int
    let cost      : Int
}

struct LineSection : Equatable {
    
    let stops       : [Station]
    let line        : Line
    let direction   : String
    let directionID : Int
    let totalTime   : Double
    var wagons      : [Wagons] = []
    
    public static func == (lhs: LineSection, rhs: LineSection) -> Bool {
        return lhs.totalTime == rhs.totalTime && lhs.direction == rhs.direction
    }
}

struct TransferSection {
    let totalTime : Double
    let videoURL  : String?
}

struct EntrySection {
    let totalTime : Double
    let type      : EntryType
    
    enum EntryType {
        case enter, exit
    }
}

struct SingleStopSection : Equatable {
    
    let stop: Station
    
    public static func == (lhs: SingleStopSection, rhs: SingleStopSection) -> Bool {
        return lhs.stop.id == rhs.stop.id
    }
}

struct ValidationSection {
    let type: Validation
}


protocol Route {
    var metadata : RouteMetadata { get }
    var from     : Station? { get }
    var to       : Station? { get }
}


struct RouteDrawMetadata {
    
    let stationKeys    : [String]
    let connectionKeys : [String]
    let transfersKeys  : [String]
    let textsKeys      : [String]
    let fromCoordinate : MapPoint
    let toCoordinate   : MapPoint
}

struct FullRoute : Route {
    
    var metadata    : RouteMetadata
    var from        : Station?
    var to          : Station?
    var sections    : [Any]
    var emergencies : [Emergency]
}
