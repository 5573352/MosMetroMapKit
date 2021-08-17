//
//  EmergencyGraphics.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 27.07.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import Foundation
import UIKit

public struct Emergency {
    
    struct StationEmergency {
        let id: Int
        let status: Status
        let title: String
        let description: String
        
        enum Status: String {
            case closed = "CLOSED"
            case emergency = "EMERGENCY"
            case info = "INFO"
        }
    }
    
    struct ConnectionEmergency {
        let id: Int
        let status: Status
        let isTransition: Bool
        let redraw: Bool
        
        enum Status: String {
            case closed = "CLOSED"
            case closedForward = "CLOSED_FORWARD"
            case closedBackward = "CLOSED_BACKWARD"
        }
    }
    
    struct AlternativeConnection {
        let id: Int
        let stationFromID: Int
        let stationToID: Int
        let svg: String
        let isTransition: Bool
        let weight: Double
        var image: CGImage? = nil
    }
    
    struct AlternativeStation {
        let id: Int
        let textData: TextDrawingData
        let tapGrid: CGRect
        let center: MapPoint
        let svg: String
    }
    
    
    let title: String
    let description: String?
    let endDate: Date
    var extraSVG: AdditionalDrawindData?
    let stations: [StationEmergency]
    let connections: [ConnectionEmergency]
    var alternativeConnections: [AlternativeConnection]
    var alternativeTransitions: [AlternativeConnection]
    var alternativeStations: [AlternativeStation]
    
    
}

