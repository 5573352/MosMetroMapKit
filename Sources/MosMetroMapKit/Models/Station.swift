//
//  Station.swift
//
//  Created by Павел Кузин on 12.04.2021.
//

import UIKit

struct Worktime: Hashable {
    let open: String
    let close: String
}

struct Exit: Hashable {
    let number: Int
    let name: String
    let coordinate: MapPoint
    let buses: [String]
    let trams: [String]
    let trolleys: [String]
}

struct TrainsSchedule: Hashable {
    
    let towardsName : String
    let items       : [Schedule]
    
    struct Schedule: Hashable {
        let isWeekend  : Bool
        let firstTrain : String
        let lastTrain  : String
        let dayType    : DayType
    }
    
    enum DayType: String {
        case odd  = "ODD"
        case even = "EVEN"
    }
    
    public static func == (lhs: TrainsSchedule, rhs: TrainsSchedule) -> Bool {
        return lhs.towardsName == rhs.towardsName
    }
}

struct Station: Hashable {
    
    public static func == (lhs: Station, rhs: Station) -> Bool {
        return lhs.id == rhs.id
    }
    
    public struct Emergency: Hashable {
        let parentEmergencyID: Int
        let title: String
        let subtitle: String
        let status: Status
        
        enum Status: String {
            case info = "INFO"
            case closed = "CLOSED"
            case emergency = "EMERGENCY"
        }
    }
    
    public enum Feature: String, CaseIterable {
        case bank      = "BANK"
        case coffee    = "COFFEE"
        case flowers   = "FLOWERS"
        case battery   = "BATTERY"
        case toilet    = "TOILET"
        case candyshop = "CANDY"
        case optics    = "OPTICS"
        case carrier   = "CARRIER"
        case theatre   = "THEATRE"
        case food      = "FOOD"
        case vending   = "VENDING"
        case print     = "PRINT"
        case sales     = "SALES"
        case invalid   = "INVALID"
        case elevator  = "ELEVATOR"
        case info      = "INFO"
        case parking   = "PARKING"
        
        var stationDesc: String {
            switch self {
            case .bank:
                return NSLocalizedString("ATM available", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .coffee:
                return NSLocalizedString("Coffee", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .flowers:
                return NSLocalizedString("Flowers shop", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .battery:
                return NSLocalizedString("Gadget charger", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .toilet:
                return NSLocalizedString("WC", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .candyshop:
                return NSLocalizedString("Candy shop", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .optics:
                return NSLocalizedString("Optics shop", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .carrier:
                return NSLocalizedString("Mobile carrier store", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .theatre:
                return NSLocalizedString("Theatre tickets", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .food:
                return NSLocalizedString("Food", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .vending:
                return NSLocalizedString("Vending", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .print:
                return NSLocalizedString("Print", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .sales:
                return NSLocalizedString("Sales point", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .invalid:
                return NSLocalizedString("Avalaible for people with low mobility", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .elevator:
                return NSLocalizedString("Elevator", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .info:
                return NSLocalizedString("Information desk", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .parking:
                return NSLocalizedString("Park and Ride", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            }
        }
        
        var image: UIImage {
            switch self {
            case .bank:
                return UIImage(named: "Bank", in: .mm_Map, compatibleWith: nil)!
            case .coffee:
                return UIImage(named: "Coffee", in: .mm_Map, compatibleWith: nil)!
            case .flowers:
                return UIImage(named: "flowers", in: .mm_Map, compatibleWith: nil)!
            case .battery:
                return UIImage(named: "Battery", in: .mm_Map, compatibleWith: nil)!
            case .toilet:
                return UIImage(named: "WC", in: .mm_Map, compatibleWith: nil)!
            case .candyshop:
                return UIImage(named: "Lollipop on Apple iOS 13 1", in: .mm_Map, compatibleWith: nil)!
            case .optics:
                return UIImage(named: "Glasses on Apple iOS 13", in: .mm_Map, compatibleWith: nil)!
            case .carrier:
                return UIImage(named: "Mobile Phone with Arrow on Apple iOS 13", in: .mm_Map, compatibleWith: nil)!
            case .theatre:
                return UIImage(named: "Performing Arts on Apple iOS 13 1", in: .mm_Map, compatibleWith: nil)!
            case .food:
                return UIImage(named: "Pizza on Apple iOS 13", in: .mm_Map, compatibleWith: nil)!
            case .vending:
                return UIImage(named: "Chocolate Bar on Apple iOS 13 1", in: .mm_Map, compatibleWith: nil)!
            case .print:
                return UIImage(named: "Printer on Apple iOS 13", in: .mm_Map, compatibleWith: nil)!
            case .sales:
                return UIImage(named: "Shopping Bags on Apple iOS 13", in: .mm_Map, compatibleWith: nil)!
            case .invalid:
                return UIImage(named: "Wheelchair Symbol on Apple iOS 13", in: .mm_Map, compatibleWith: nil)!
            case .elevator:
                return UIImage(named: "Elevator on Emojipedia 13 1", in: .mm_Map, compatibleWith: nil)!
            case .info:
                return UIImage(named: "Woman Raising Hand on Apple iOS 13", in: .mm_Map, compatibleWith: nil)!
            case .parking:
                return UIImage(named: "P Button on Apple iOS 13", in: .mm_Map, compatibleWith: nil)!
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
