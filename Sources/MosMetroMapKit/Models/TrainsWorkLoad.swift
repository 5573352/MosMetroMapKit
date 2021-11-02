//
//  TrainsWorkLoad.swift
//
//  Created by Павел Кузин on 21.04.2021.
//

import Foundation

struct TrainWorkload {
    
    let wayData: [WayData]
    
    struct WayData {
        let towardsStationName  : String
        let towardsStationOrder : Int
        let towardsStationID    : Int
        let data                : [TrainData]
    }
    
    struct TrainData {
        let trainNumber    : String
        let status         : WagonState
        let arrivalTime    : Int
        let wagonsWorkload : [Workload]
    }
    
    enum WagonState {
        case standing, moving
        
        static func state(time: Int) -> WagonState {
            if (time != 0) { return .moving } else { return .standing }
        }
    }
    
    enum Workload: String {
        case low        = "low"
        case high       = "high"
        case medium     = "medium"
        case unknown    = "unknown"
        case mediumHigh = "mediumHigh"
    }
}

extension TrainWorkload {
    
    static private func parseTrains(towardsName: String, towardsStationOrder: Int, towardsStationID: Int, subjson: JSON) -> WayData {
        var trains = [TrainData]()
        for (_,train) in subjson {
            let arrivalTime = train["arrivalTime"].intValue
            let wagonsDict = train["wagons"].dictionaryValue.reduce(into: [Int:String](), { result, x in
                if let key = Int(x.key) {
                   result[key] = x.value.stringValue
                }
            })
            
            let sorted = wagonsDict.sorted(by: { $0.key < $1.key })
            
            let trainData = TrainData(
                trainNumber: train["id"].stringValue,
                status: WagonState.state(time: arrivalTime),
                arrivalTime: arrivalTime,
                wagonsWorkload: sorted.compactMap { Workload(rawValue: $0.value ) }
            )
            trains.append(trainData)
        }
        
        let wayData = WayData(towardsStationName: towardsName, towardsStationOrder: towardsStationOrder, towardsStationID: towardsStationID, data: trains.sorted(by: { $0.arrivalTime < $1.arrivalTime }))
        return wayData
    }
    
    static func map(json: JSON, station: Station, all: [StationDTO]) -> TrainWorkload? {
        var wayDataArray = [WayData]()
        print(json)
        for (key,subjson) in json["data"] {
            if let fromID = Int(key) {
                if fromID == -1 {
                    // Это первая станция линии
                    if station.id == station.line.firstStationID {
                        guard let lastLineStationDTO = all.filter({ $0.id == station.line.lastStationID }).first else { continue }
                        var towardsName = String.localizedStringWithFormat(NSLocalizedString("Towards %@", tableName: nil, bundle: .mm_Map, value: "", comment: ""), Localize.currentLanguage() == "ru" ? lastLineStationDTO.name_ru : lastLineStationDTO.name_en )
                        if let prompt = lastLineStationDTO.line?.firstStationPrompt {
                            towardsName = "\(prompt) \(towardsName)"
                        }
                        wayDataArray.append(self.parseTrains(towardsName: towardsName, towardsStationOrder: lastLineStationDTO.lineOrder, towardsStationID: lastLineStationDTO.id, subjson: subjson))
                    } else {
                    // Это другая сторона линии
                        guard let lastLineStationDTO = all.filter({ $0.id == station.line.lastStationID }).first else { continue }
                        var towardsName = String.localizedStringWithFormat(NSLocalizedString("Towards %@", tableName: nil, bundle: .mm_Map, value: "", comment: ""), Localize.currentLanguage() == "ru" ? lastLineStationDTO.name_ru : lastLineStationDTO.name_en )
                        if let prompt = lastLineStationDTO.line?.lastStationPrompt {
                            towardsName = "\(prompt) \(towardsName)"
                        }
                        wayDataArray.append(self.parseTrains(towardsName: towardsName, towardsStationOrder: lastLineStationDTO.lineOrder, towardsStationID: lastLineStationDTO.id, subjson: subjson))
                    }
                } else {
                   guard let fromStation = all.filter({ $0.id == fromID }).first, let line = fromStation.line else { continue }
                    let lastLineStationID = fromStation.lineOrder > station.ordering ? line.firstStationID : line.lastStationID
                    guard let lastLineStationDTO = all.filter({ $0.id == lastLineStationID }).first else { continue }
                    var towardsName = String.localizedStringWithFormat(NSLocalizedString("Towards %@", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
                                                                       Localize.currentLanguage() == "ru" ? lastLineStationDTO.name_ru : lastLineStationDTO.name_en )
                    if fromStation.lineOrder > station.ordering {
                        if let prompt = lastLineStationDTO.line?.firstStationPrompt {
                            towardsName = "\(prompt) \(towardsName)"
                        }
                    } else {
                        if let prompt = lastLineStationDTO.line?.lastStationPrompt {
                            towardsName = "\(prompt) \(towardsName)"
                        }
                    }
                    wayDataArray.append(self.parseTrains(towardsName: towardsName, towardsStationOrder: lastLineStationDTO.lineOrder, towardsStationID: lastLineStationID, subjson: subjson))
                }
            }
        }
    
        return wayDataArray.isEmpty ? nil : TrainWorkload(wayData: wayDataArray.sorted(by: { $0.towardsStationOrder < $1.towardsStationOrder }))
    }
}
