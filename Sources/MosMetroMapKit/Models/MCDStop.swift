//
//  MCDStop.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 21.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit
import SwiftDate
import SwiftyJSON

struct MCDStop {
    let arrival     : Date
    let passing     : Bool
    let platform    : Int?
    let order       : Int
    let fact        : Date?
    let stationName : String
    let color       : UIColor
    
    var status      : MCDStatus {
        return getStatus()
    }
}

extension MCDStop {
    
    static private func map(data: JSON, all: [StationDTO]) -> MCDStop? {
        if let arrival = data["prib"].string?.toDate()?.date, let stationDTO = all.filter({ $0.id == data["stationId"].intValue }).first, let line = stationDTO.line {
            return MCDStop(arrival: arrival,
                           passing: data["passing"].boolValue,
                           platform: data["platform"].int,
                           order: data["seq"].intValue,
                           fact: data["fact"].string?.toDate()?.date,
                           stationName: stationDTO.name,
                           color: line.uiColor)
        }
        return nil
    }
    
    static public func getStops(by idtr: Int, for all: [StationDTO], callback: @escaping (Result<[MCDStop],FutureNetworkError>) -> ()) {
        let service = FutureNetworkService()
        let req = Request(httpMethod: .GET, httpProtocol: .HTTPS, contentType: .json, endpoint: .thread , body: nil, baseURL: "devapp.mosmetro.ru", lastComponent: "\(idtr)")
        service.request(req, callback: { result in
            switch result {
            case .success(let response):
                if let arr = JSON(response.data)["data"].array {
                    let stops = arr.compactMap { MCDStop.map(data: $0, all: all) }
                    callback(.success(stops))
                    return
                } else {
                    let err = FutureNetworkError(statusCode: nil, kind: .invalidJSON, errorDescription: "Wrong data")
                    callback(.failure(err))
                    return
                }
            case .failure(let error):
                callback(.failure(error))
                return
            }
        })
    }
    
    private func getStatus() -> MCDStatus {
        if let fact = fact {
            let moscow = Region(calendar: Calendars.gregorian, zone: Zones.europeMoscow, locale: Locales.russianRussia)
            let arrivalRegionDate = DateInRegion(arrival, region: moscow).dateByAdding(-3, .hour)
            let factDate = DateInRegion(fact, region: moscow).dateByAdding(-3, .hour)
            let period = TimePeriod(start: arrivalRegionDate, end: factDate)
            return period.minutes > 0 ? .late(period.minutes) : .early(abs(period.minutes))
        } else {
            return .standart
        }
    }
}
