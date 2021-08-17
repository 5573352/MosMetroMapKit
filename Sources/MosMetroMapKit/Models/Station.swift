//
//  Station.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 12.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit

public struct Worktime: Hashable {
    let open: String
    let close: String
}

public struct Exit: Hashable {
    let number: Int
    let name: String
    let coordinate: MapPoint
    let buses: [String]
    let trams: [String]
    let trolleys: [String]
}

public struct TrainsSchedule: Hashable {
    public static func == (lhs: TrainsSchedule, rhs: TrainsSchedule) -> Bool {
        return lhs.towardsName == rhs.towardsName
    }
    
    let towardsName: String
    let items: [Schedule]
    
    struct Schedule: Hashable {
        let isWeekend: Bool
        let firstTrain: String
        let lastTrain: String
        let dayType: DayType
    }
    
    enum DayType: String {
        case odd = "ODD"
        case even = "EVEN"
    }
}

public struct Station: Hashable {
    
    public static func == (lhs: Station, rhs: Station) -> Bool {
        return lhs.id == rhs.id
    }
    
    public struct Emergency: Hashable {
        let parentEmergencyID: Int
        let title: String
        let subtitle: String
        let status: Status
        
        enum Status: String {
            case closed = "CLOSED"
            case emergency = "EMERGENCY"
            case info = "INFO"
        }
    }
    
    public enum Feature: String, CaseIterable {
        case bank = "BANK"
        case coffee = "COFFEE"
        case flowers = "FLOWERS"
        case battery = "BATTERY"
        case toilet = "TOILET"
        case candyshop = "CANDY"
        case optics = "OPTICS"
        case carrier = "CARRIER"
        case theatre = "THEATRE"
        case food = "FOOD"
        case vending = "VENDING"
        case print = "PRINT"
        case sales = "SALES"
        case invalid = "INVALID"
        case elevator = "ELEVATOR"
        case info = "INFO"
        case parking = "PARKING"
        
        var stationDesc: String {
            switch self {
            case .bank:
                return "ATM available".localized()
            case .coffee:
                return "Coffee".localized()
            case .flowers:
                return "Flowers shop".localized()
            case .battery:
                return "Gadget charger".localized()
            case .toilet:
                return "WC".localized()
            case .candyshop:
                return "Candy shop".localized()
            case .optics:
                return "Optics shop".localized()
            case .carrier:
                return "Mobile carrier store".localized()
            case .theatre:
                return "Theatre tickets".localized()
            case .food:
                return "Food".localized()
            case .vending:
                return "Vending".localized()
            case .print:
                return "Print".localized()
            case .sales:
                return "Sales point".localized()
            case .invalid:
                return "Avalaible for people with low mobility".localized()
            case .elevator:
                return "Elevator".localized()
            case .info:
                return "Information desk".localized()
            case .parking:
                return "Park and Ride".localized()
            }
        }
        
        var image: UIImage {
            switch self {
            case .bank:
                return #imageLiteral(resourceName: "Bank")
            case .coffee:
                return #imageLiteral(resourceName: "Coffee")
            case .flowers:
                return #imageLiteral(resourceName: "flowers")
            case .battery:
                return #imageLiteral(resourceName: "Battery")
            case .toilet:
                return #imageLiteral(resourceName: "WC")
            case .candyshop:
                return #imageLiteral(resourceName: "Lollipop on Apple iOS 13 1")
            case .optics:
                return #imageLiteral(resourceName: "Glasses on Apple iOS 13")
            case .carrier:
                return #imageLiteral(resourceName: "Mobile Phone with Arrow on Apple iOS 13")
            case .theatre:
                return #imageLiteral(resourceName: "Performing Arts on Apple iOS 13 1")
            case .food:
                return #imageLiteral(resourceName: "Pizza on Apple iOS 13")
            case .vending:
                return #imageLiteral(resourceName: "Chocolate Bar on Apple iOS 13 1")
            case .print:
                return #imageLiteral(resourceName: "Printer on Apple iOS 13")
            case .sales:
                return #imageLiteral(resourceName: "Shopping Bags on Apple iOS 13")
            case .invalid:
                return #imageLiteral(resourceName: "Wheelchair Symbol on Apple iOS 13")
            case .elevator:
                return #imageLiteral(resourceName: "Elevator on Emojipedia 13 1")
            case .info:
                return #imageLiteral(resourceName: "Woman Raising Hand on Apple iOS 13")
            case .parking:
                return #imageLiteral(resourceName: "P Button on Apple iOS 13")
            }
        }
    }
    
    let id: Int
    let name: String
    let line: Line
    let mapPoint: MapPoint
    let geoPoint: MapPoint
    let ordering: Int
    let emergency: [Emergency]
    
    var transitions: [Station]?
    var prevousStationOrder: Int?
    var nextStationOrder: Int?
    let worktime: Worktime
    let isMCD: Bool
    let isOutside: Bool
    let isMCC: Bool
    let features: [Feature]
    let exits: [Exit] = []
    let enterTime: Int
    let exitTime: Int
    let schedule: [TrainsSchedule]
}
