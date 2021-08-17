//
//  MCDSchedule.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 20.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit
import SwiftDate
import SwiftyJSON

enum MCDStatus {
    case late(Int)
    case early(Int)
    case standart
    
    func color() -> UIColor {
        switch self {
        case .late(_)  :
            return .metroRed
        case .early(_) :
            return .metroGreen
        case .standart :
            return .metroGreen
        }
    }
}

struct MCDThread {
    let arrival  : Date
    let passing  : Bool
    let platform : Int?
    let trainNum : Int
    let fact     : Date?
    let idtr     : Int
    
    var status   : MCDStatus {
        return getStatus()
    }
    
    func getArrivalString() -> String {
        let moscow = Region(calendar: Calendars.gregorian, zone: Zones.europeMoscow, locale: Locales.russianRussia)
        let arrivalRegion = DateInRegion(arrival, region: moscow).dateByAdding(-3, .hour)
        let currentDate = DateInRegion(Date(), region: moscow)
        let period = TimePeriod(start: currentDate, end: arrivalRegion)
        print(period.minutes)
        if period.minutes < 1 {
            return "Arrived".localized()
        } else {
            return "\("In".localized()) \(String.localizedStringWithFormat("%d min".localized(), period.minutes))"
        }
    }

    private func getStatus() -> MCDStatus {
        if let fact = fact {
            let moscow = Region(calendar: Calendars.gregorian, zone: Zones.europeMoscow, locale: Locales.russianRussia)
            let arrivalRegion = DateInRegion(arrival, region: moscow).dateByAdding(-3, .hour)
            let currentDate = DateInRegion(fact, region: moscow).dateByAdding(-3, .hour)
            let period = TimePeriod(start: currentDate, end: arrivalRegion)
            return period.minutes > 0 ? .late(period.minutes) : .early(abs(period.minutes))
            
        } else {
            return .standart
        }
    }
}

struct MCDSchedule {
    let start : [MCDThread]
    let end   : [MCDThread]
    
    static func loadSchedule(by stationID: Int, callback: @escaping (Result<MCDSchedule,FutureNetworkError>) -> ()) {
        let service = FutureNetworkService()
        
        let req = Request(httpMethod: .GET, httpProtocol: .HTTPS, contentType: .json, endpoint: .schedule , body: nil, baseURL: "devapp.mosmetro.ru", lastComponent: "\(stationID)")
        service.request(req, callback: { result in
            switch result {
            case .success(let response):
                if let arrayStart = JSON(response.data)["data"]["START"].array, let arrayEnd =  JSON(response.data)["data"]["END"].array{
                    let threadsStart = arrayStart.compactMap { MCDThread.map(data: $0) }
                    let threadsEnd = arrayEnd.compactMap { MCDThread.map(data: $0) }
                    callback(.success(MCDSchedule(start: threadsStart, end: threadsEnd)))
                    return
                } else {
                    let err = FutureNetworkError(statusCode: nil, kind: .invalidJSON, errorDescription: "Wrong data")
                    callback(.failure(err))
                    return
                }
            case .failure(let err):
                print("error")
                callback(.failure(err))
                return
            }
        })
    }
}

extension MCDThread {
    
    static func map(data: JSON) -> MCDThread? {
        if let arrival = data["prib"].string?.toDate()?.date {
            return MCDThread(arrival: arrival,
                             passing: data["passing"].boolValue,
                             platform: data["platform"].int,
                             trainNum: data["numo"].intValue,
                             fact: data["fact"].string?.toDate()?.date,
                             idtr: data["idtr"].intValue)
        }
        return nil
    }
    
    static func getNearestIndex(threads: [MCDThread]) -> Int? {
        let date = Date().dateByAdding(3, .hour).date
        threads.forEach { print($0.arrival.toString())}
        if let index = threads.firstIndex(where: { $0.arrival > date } ) {
            return index
        }
        return nil
    }
    
    static func getNearestThree(threads: [MCDThread]) -> [MCDThread]? {
        if let index = self.getNearestIndex(threads: threads) {
            var items = [MCDThread]()
            if let first = threads[safe: index] {
                items.append(first)
            }
            if let second = threads[safe: index+1] {
                items.append(second)
            }
            if let third = threads[safe: index+2] {
                items.append(third)
            }
            return items
        }
        return nil
    }
}
