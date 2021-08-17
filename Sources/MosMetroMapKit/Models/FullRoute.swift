//
//  Route.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 25.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import Foundation

public enum Wagons: String {
    case all = "ALL"
    case first = "FIRST"
    case nearFirst = "NEAR_FIRST"
    case center = "CENTER"
    case nearEnd = "NEAR_END"
    case end = "END"
}

public enum Validation {
    case entryPayment(Int?)
    case exitPayment(Int?)
}

public struct RouteMetadata {
    let totalTime: Double
    let transfers: Int
    let cost: Int
}

public struct LineSection: Equatable {
    public static func == (lhs: LineSection, rhs: LineSection) -> Bool {
        return lhs.totalTime == rhs.totalTime && lhs.direction == rhs.direction
    }
    
    let stops: [Station]
    let line: Line
    let direction: String
    let directionID: Int
    let totalTime: Double
    var wagons: [Wagons] = []
}

public struct TransferSection {
    let totalTime: Double
    let videoURL: String?
}

public struct EntrySection {
    let totalTime: Double
    let type: EntryType
    enum EntryType {
        case enter, exit
    }
}

public struct SingleStopSection: Equatable {
    public static func == (lhs: SingleStopSection, rhs: SingleStopSection) -> Bool {
        return lhs.stop.id == rhs.stop.id
    }

    let stop: Station
}

public struct ValidationSection {
    let type: Validation
}


public protocol Route {
    var metadata: RouteMetadata { get }
    var from: Station? { get }
    var to: Station? { get }
}


public struct RouteDrawMetadata {
    
    let stationKeys: [String]
    let connectionKeys: [String]
    let transfersKeys: [String]
    let textsKeys: [String]
    let fromCoordinate: MapPoint
    let toCoordinate: MapPoint
}

public struct FullRoute: Route {
    
    public var metadata: RouteMetadata
    
    public var from: Station?
    
    public var to: Station?
    
    var sections: [Any]
    
    var emergencies: [Emergency]
        
    
}
