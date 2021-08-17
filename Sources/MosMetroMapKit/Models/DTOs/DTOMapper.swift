//
//  DTOMapper.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 12.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit
import Localize_Swift
import SwiftDate

public class DTOMapper {
    
    public var stations : [Int : StationDTO]?
    public var service  : MetroService?
    
    public func get(by id: Int) -> StationDTO? {
        guard let stations = stations else { return nil }
        let keyExists = stations[id] != nil
        if keyExists {
            return stations[id]
        } else {
            return nil
        }
    }
    
    func processWorktime(_ dto: WorktimeDTO, dayIndex: Int) -> Worktime? {
        // Отнимаем -1, т.к. отсчет в грегорианском календаре идет с воскресенья
        let currentDayIndex = DateInRegion().weekday - 1
        if dayIndex == currentDayIndex {
            return Worktime(open: dto.open, close: dto.close)
        }
        return nil
    }
    
    private func internalMap(dto: StationDTO) -> Station? {
        guard let lineDTO = dto.line else { return nil }
        let line     = self.map(lineDTO)
        let name     = Localize.currentLanguage() == "ru" ? dto.name_ru : dto.name_en
        let mapPoint = MapPoint(x: dto.x, y: dto.y)
        let geoPoint = MapPoint(latitude: dto.latitude, longitude: dto.longitude)
        var worktime = Worktime(open: "05:30", close: "01:00")
        for (index,worktimeDTO) in dto.worktime.enumerated() {
            if let wTime = self.processWorktime(worktimeDTO, dayIndex: index) {
                worktime = wTime
            }
        }
        var schedules = [TrainsSchedule]()
        for schedule in dto.trainsSchdule {
            guard let service = self.service, let _ = self.stations else { continue }
            if let toStation = service.get(by: schedule.toID), let _line = toStation.line {
                let towardsID = toStation.lineOrder > dto.lineOrder ? _line.lastStationID : _line.firstStationID
                guard let towardsStation = self.get(by: towardsID) else { continue }
                let towardsName = Localize.currentLanguage() == "ru" ? towardsStation.name_ru : towardsStation.name_en
                let items: [TrainsSchedule.Schedule] = schedule.schedules.map { return TrainsSchedule.Schedule(isWeekend: $0.isWeekend, firstTrain: $0.first, lastTrain: $0.last, dayType: TrainsSchedule.DayType(rawValue: $0.dayType) ?? .even) }
                schedules.append(TrainsSchedule(towardsName: towardsName, items: items))
            }
        }
        guard let service = service else { return nil }
        let station = Station(id                  : dto.id,
                              name                : name,
                              line                : line,
                              mapPoint            : mapPoint,
                              geoPoint            : geoPoint,
                              ordering            : dto.lineOrder,
                              emergency           : service.getStationEmergency(station: dto.id),
                              transitions         : nil,
                              prevousStationOrder : nil,
                              nextStationOrder    : nil,
                              worktime            : worktime,
                              isMCD               : dto.isMCD,
                              isOutside           : dto.isOutside,
                              isMCC               : dto.isMCC,
                              features            : dto.services.compactMap { Station.Feature(rawValue: $0) },
                              enterTime           : dto.enterTime,
                              exitTime            : dto.exitTime,
                              schedule            : schedules)
        return station
    }
    
    func mapAllStations(dto: [StationDTO]) -> [Station] {
        let stations = dto.map {
            self.map(dto: $0)
        }.compactMap({ $0 })
        return stations
    }
    
    func map(dto: StationDTO) -> Station? {
        guard var station = self.internalMap(dto: dto) else { return nil }
        if !dto.transitions.isEmpty {
            var transitionStations = [Station]()
            for item in dto.transitions {
                guard let station = self.internalMap(dto: item) else { continue }
                transitionStations.append(station)
            }
            
            for (index, transitionStation) in transitionStations.enumerated() {

                guard let transitionDTO = self.get(by: transitionStation.id) else { continue }
                var newTransitions = [Station]()
                for trans in transitionDTO.transitions {
                    guard let newTransition = self.internalMap(dto: trans) else { continue }
                    newTransitions.append(newTransition)
                }
                transitionStations[index].transitions = newTransitions
            }
            station.transitions = transitionStations
        }
        return station
    }
    
    func map(_ dto: LineDTO) -> Line {
        let color = UIColor.hexStringToUIColor(hex: dto.color)
        let name = Localize.currentLanguage() == "ru" ? dto.name_ru : dto.name_en
        let originalIcon = UIImage(named: "line_\(dto.order)") ?? UIImage()
        let invertedIcon = UIImage(named: "line_\(dto.order) inverted") ?? UIImage()
        let neighbourLines = [Line.NeighbourLine]()
//        for lineID in dto.neighbourLinesIDs {
//            if let neighbourLineDTO = realmContext.fetch(LineDTO.self, primaryKey: lineID) {
//                let line = map(neighbourLineDTO)
//                neighbourLines.append(Line.NeighbourLine(id: line.id, name: line.name, color: line.color, originalIcon: line.originalIcon, invertedIcon: line.invertedIcon, firstStationID: line.firstStationID, lastStationID: line.lastStationID))
//            }
//        }
        return Line(id: dto.id, name: name, color: color, originalIcon: originalIcon, invertedIcon: invertedIcon, firstStationID: dto.firstStationID, lastStationID: dto.lastStationID, neigbourLines: neighbourLines)
    }
    
    static func map(_ dto: EmergencyDTO) -> Emergency {
        let stations: [Emergency.StationEmergency] = dto.stations.map {  Emergency.StationEmergency(id: $0.stationID, status: Emergency.StationEmergency.Status(rawValue: $0.status) ?? .info, title: Localize.currentLanguage() == "ru" ? $0.title_ru : $0.title_en, description: Localize.currentLanguage() == "ru" ? $0.desc_ru : $0.desc_en) }
        let connections: [Emergency.ConnectionEmergency] = dto.connections.map { return Emergency.ConnectionEmergency(
            id: $0.connectionID,
            status: Emergency.ConnectionEmergency.Status(rawValue: $0.status) ?? .closed,
            isTransition: $0.isTransition,
            redraw: $0.redraw) }
        
        let alternatives: [Emergency.AlternativeConnection] = dto.alternativeConnections.map {
            return Emergency.AlternativeConnection(id: $0.id, stationFromID: $0.fromStationID, stationToID: $0.toStationID, svg: $0.svg, isTransition: false, weight: $0.weight)
            
        }
        var title = ""
        if Localize.currentLanguage() == "ru" {
            title = dto.title_ru
        } else {
            if dto.title_en == "default" {
                title = dto.title_ru
            } else {
                title = dto.title_en
            }
        }
        var desc: String? = Localize.currentLanguage() == "ru" ? dto.desc_ru : dto.desc_en
        if desc == "no" {
            desc = nil
        }
        return Emergency(title: title,
                         description: desc,
                         endDate: dto.endDate,
                         extraSVG: GraphicsUtils.parseSingleAddtional(dto.extraSVG),
                         stations: stations,
                         connections: connections,
                         alternativeConnections: alternatives,
                         alternativeTransitions: [],
                         alternativeStations: [])
    }
}

