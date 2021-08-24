//
//  MetroService.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 12.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit
import Macaw
import SWXMLHash
import SwiftyJSON
import CoreLocation
import Localize_Swift

public enum MetroErrors: Error {
    case routeNotFound
    case sameStations
    case vertexNotFound
}

extension MetroErrors: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .routeNotFound:
            return NSLocalizedString("Route not found", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        case .sameStations:
            return NSLocalizedString("Same stations", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        case .vertexNotFound:
            return NSLocalizedString("Vertex not found", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        }
    }
}

typealias EdgeRoute = (edges: [Edge], time: Double, transfers: Int)

struct MMDataHash {
    
    enum HashType: String {
        case stations    = "stationsHash"
        case lines       = "linesHash"
        case connections = "connectionsHash"
        case transitions = "transitionsHash"
        case schema      = "schemaHash"
    }
    
    func save(_ hash: String, type: HashType) {
        let ud = UserDefaults.standard
        ud.setValue(hash, forKey: type.rawValue)
    }
    
    var stationsHash: String {
        let ud = UserDefaults.standard
        if let hash = ud.string(forKey: "stationsHash") {
            return hash
        } else {
            return ""
        }
    }
    
    var connectionsHash: String {
        let ud = UserDefaults.standard
        if let hash = ud.string(forKey: "connectionsHash") {
            return hash
        } else {
            return ""
        }
    }
    
    var transitionsHash: String {
        let ud = UserDefaults.standard
        if let hash = ud.string(forKey: "transitionsHash") {
            return hash
        } else {
            return ""
        }
    }
    
    var linesHash: String {
        let ud = UserDefaults.standard
        if let hash = ud.string(forKey: "linesHash") {
            return hash
        } else {
            return ""
        }
    }
    
    var schemaHash: String {
        let ud = UserDefaults.standard
        if let hash = ud.string(forKey: "schemaHash") {
            return hash
        } else {
            return ""
        }
    }
    
}

public class MetroService: NSObject {
    
    //Public
    public var graph             = Graph()
    public var mapper            : DTOMapper?
    public var tapGrids          = [Int: CGRect]()
    public var onLocationUpdate  : (() -> ())?
    public var mapDrawingOptions : MapDrawingOptions?
    public var emergencies       : [Emergency]        = []
    public var emergenciesDTO    : [EmergencyDTO]     = []
    public var stations          : [Station]          = []
    public var stationsDTO       : [Int : StationDTO] = [:] {
        didSet {
            guard let mapper = self.mapper else { return }
            mapper.stations = stationsDTO
        }
    }
    
    //Private
    private var coordinates     = [Int: MapPoint]()
    private let locationManager = CLLocationManager()
    private var linesDTO        : [LineDTO]       = []
    private var connectionsDTO  : [EdgeDTO]       = []
    private var revercedConDTO  : [EdgeDTO]       = []
    private var transitionsDTO  : [TransitionDTO] = []
    private var revercedTranDTO : [TransitionDTO] = []
    private var mapSizeDto = MapSizeDTO()

    public func loadAllDatabase(callback: @escaping (Bool) -> ()) {
        let start = CFAbsoluteTimeGetCurrent()
        let service = FutureNetworkService()
        let queue = DispatchQueue(label: "com.mosmetro.schema", qos: .userInitiated)
        let schemaRequest = Request(httpMethod: .GET, httpProtocol: .HTTPS, contentType: .json, endpoint: .schema, body: nil, baseURL: "prodapp.mosmetro.ru", lastComponent: nil)
        service.request(schemaRequest, callback: { result in
            switch result {
            case .success(let data):
                let schemaJSON = JSON(data.data)
                queue.async {
                    var lines       = [LineDTO]()
                    var stations    = [Int:StationDTO]()
                    var connections = [EdgeDTO]()
                    var transitions = [TransitionDTO]()
                        
                    for (_, data) in schemaJSON["data"]["lines"] {
                        let line = LineDTO()
                        line.map(data)
                        self.linesDTO.append(line)
                        lines.append(line)
                    }
                        
                    for (_, data) in schemaJSON["data"]["stations"] {
                        let station = StationDTO()
                        station.map(data, lines: lines)
                        self.stationsDTO.updateValue(station, forKey: station.id)
                        stations.updateValue(station, forKey: station.id)
                    }
                            
                    for (_, data) in schemaJSON["data"]["connections"] {
                        let edge = EdgeDTO()
                        edge.map(data, stations: stations)
                        let edgeReversed = EdgeDTO()
                        edgeReversed.mapReversed(data, stations: stations)
                        connections.append(edge)
                        self.connectionsDTO.append(edge)
                        connections.append(edgeReversed)
                        self.connectionsDTO.append(edgeReversed)
                    }
                        
                    for (_, data) in schemaJSON["data"]["transitions"] {
                        let transition = TransitionDTO()
                        transition.map(data, stations: stations)
                            
                        let reversedTransition = TransitionDTO()
                        reversedTransition.mapReversed(data, stations: stations)
                        transitions.append(transition)
                        self.transitionsDTO.append(transition)
                        transitions.append(reversedTransition)
                        self.transitionsDTO.append(reversedTransition)
                    }
                    
                    var additionalsDrawings = [AdditionalDrawingDTO]()
                    for (_, data) in schemaJSON["data"]["additional"] {
                        let addDrawingDTO = AdditionalDrawingDTO()
                        addDrawingDTO.svg = data["svg"].stringValue
                        additionalsDrawings.append(addDrawingDTO)
                    }
                    
                    self.mapSizeDto.width  = schemaJSON["data"]["width"]  .doubleValue
                    self.mapSizeDto.height = schemaJSON["data"]["height"] .doubleValue
                    self.buildGraph(false)
                    callback(true)
                    let diff = CFAbsoluteTimeGetCurrent() - start
                    debugPrint("took \(diff) secs to make resp")
                    return
                }
            case .failure(_):
                callback(false)
                return
            }
        })
    }
    
    public init(isPerspective: Bool) {
        super.init()
        self.mapper = DTOMapper()
        self.mapper?.service = self
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    public func get(by id: Int) -> StationDTO? {
        guard let mapper = self.mapper else { return nil }
        return mapper.get(by: id)
    }
}

extension MetroService: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let _: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        onLocationUpdate?()
    }
}

// MARK: – Public methods
extension MetroService {
    
    //MARK: - SearchNearestStation
    public func searchNearestStation(callback: @escaping (Int?) -> ()) {
        guard let userLocation = userLocation() else { callback(nil); return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var nearestID = 0
            var maxValue  = 999999990.0
            self?.coordinates.forEach {
                let distance = CLLocation(latitude: $0.value.x, longitude: $0.value.y).distance(from: CLLocation(latitude: userLocation.x, longitude: userLocation.y))
                if  distance < maxValue {
                    nearestID = $0.key
                    maxValue = distance
                }}
            callback(nearestID)
        }
    }
    
    public func userLocation() -> MapPoint? {
        guard let locationValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return nil }
        return MapPoint(latitude: locationValue.latitude, longitude: locationValue.longitude)
    }
    
    //MARK: - Emergencies
    public func getEmergencies(_ callback: @escaping ([Emergency]) -> () ) {
        let networkService = FutureNetworkService()
        let req = Request(httpMethod: .GET, httpProtocol: .HTTPS, contentType: .json, endpoint: .notif, body: nil, baseURL: "prodapp.mosmetro.ru", lastComponent: nil)
        networkService.request(req) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let res):
                let data = JSON(res.data)
                let emergencies = self.processEmergencies(with: data)
                if let mapper = self.mapper {
                    self.emergencies = emergencies
                    self.stations = mapper.mapAllStations(dto: Array(self.stationsDTO.values))
                }
                callback(emergencies)
            case .failure(_):
                print("FAILURE")
            }
        }
    }
    
    public func getStationEmergency(station id: Int) -> [Station.Emergency] {
        var returnedValue = [Station.Emergency]()
        for emergency in emergenciesDTO {
            let stations = Array(emergency.stations)
            let filtered = stations.filter {  $0.stationID == id }
            if filtered.isEmpty {
                continue
            } else {
                let title = Localize.currentLanguage() == "ru" ? filtered[0].title_ru : filtered[0].title_en
                let subtitle = Localize.currentLanguage() == "ru" ? filtered[0].desc_ru : filtered[0].desc_en
                returnedValue.append(Station.Emergency(parentEmergencyID: emergency.id, title: title, subtitle: subtitle, status: Station.Emergency.Status(rawValue: filtered[0].status) ?? .info))
            }
        }
        return returnedValue
    }
    
    //MARK: - Route
    public func route(from: Station, to: Station, options: RoutingOptions, completion: @escaping (Result<[ShortRoute],MetroErrors>) -> () ) {
        let start = CFAbsoluteTimeGetCurrent()
        if from.id == to.id {
            completion(.failure(.sameStations))
            return
        }
        
        guard let vertexFrom = graph.vertex(by: from.id), let vertexTo = graph.vertex(by: to.id) else {
            completion(.failure(.vertexNotFound))
            return
        }
        var routes = [ShortRoute]()
        var shortestPaths = [EdgeRoute]()
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            let pathFinder = AStarPathfinder<Vertex,Graph>(pathable: self.graph)
            let path = pathFinder.path(from: vertexFrom, to: vertexTo)
            
            let edgesPath = self.graph.constructPath(from: path.map { $0.nodeKey })
            let firstRoute: EdgeRoute = (edges: edgesPath,
                                         time: edgesPath.reduce(0, { x, y in x + y.weight }),
                                         transfers: edgesPath.filter { $0.isTransition }.count)
            // Если пересадок 0 , то маршрут оптимальный
            if firstRoute.transfers == 0 {
                guard let route = self.constructShortRoute(edges: edgesPath) else {
                    completion(.failure(.routeNotFound))
                    return }
                completion(.success([route]))
                return
            } else {
                shortestPaths.append(firstRoute)
                
                if firstRoute.transfers == 1 && firstRoute.time < 600 {
                    guard let route = self.constructShortRoute(edges: edgesPath) else {
                        completion(.failure(.routeNotFound))
                        return }
                    completion(.success([route]))
                    return
                }
                
                var editedEdges = [Edge]()
                //let graphCopy = self.graph.copy() as! GraphTest
                
                for i in 0...3 {
                    guard let route = shortestPaths[safe: i] else { continue }
                    if !(route.transfers == 0) {
                        let transitionsIndexes = route.edges.indices.filter { route.edges[$0].isTransition }
                        guard let firstIndex = transitionsIndexes.first else { continue }
                        if route.transfers == 1 {
                            if route.edges[safe: firstIndex] != nil {
                                editedEdges.append(route.edges[firstIndex])
                                pathFinder.pathable?.remove(edge: route.edges[firstIndex])
                            }
                            
                        } else {
                            if route.edges[safe: firstIndex+1] != nil {
                                editedEdges.append(route.edges[firstIndex+1])
                                pathFinder.pathable?.remove(edge: route.edges[firstIndex+1])
                            }
                            
                            
                        }
                        
                        
                        let newPath = pathFinder.path(from: vertexFrom, to: vertexTo)
                        
                        if newPath.isEmpty { continue }
                        let constructedPath = self.graph.constructPath(from: newPath.map { $0.nodeKey })
                        shortestPaths.append((edges: constructedPath,
                                              time: constructedPath.reduce(0, { x, y in x + y.weight }),
                                              transfers: constructedPath.filter { $0.isTransition }.count))
                    } else {
                        break
                    }
                }
                switch options.routeSorting {
                
                case .leastTime:
                    shortestPaths.sort(by: { (route1,route2) in
                        route1.time < route2.time
                    })
                case .classic:
                    shortestPaths.sort(by: { (route1,route2) in
                        (route1.transfers,route1.time) < (route2.transfers,route2.time)
                    })
                    shortestPaths.sort(by: { (route1,route2) in
                        if route1.time < route2.time {
                            let diff = route2.time - route1.time
                            if diff > (8 * 60) {
                                
                                return true
                            } else {
                                return false
                            }
                        } else {
                            return false
                        }
                    })
                    
                    if !(vertexFrom.isMCC || vertexTo.isMCC) {
                        for (index,path) in shortestPaths.enumerated() {
                            if path.edges.contains(where: { $0.destination.isMCC || $0.source.isMCC } ) {
                                if (index + 1) < (shortestPaths.endIndex - 1) {
                                    shortestPaths.swapAt(index, index+1)
                                }
                                
                            }
                        }
                    }
                case .leastTransfers:
                    shortestPaths.sort(by: { (route1,route2) in
                        route1.transfers < route2.transfers
                    })
                }
                let minTime = shortestPaths.min(by: { $0.time < $1.time })
                if let minimalTime = minTime?.time {
                    shortestPaths = shortestPaths.filter { $0.time < (minimalTime + 60 * 25) }
                }
                let uniqueRoutes = shortestPaths.map { $0.edges }.uniqued()
                let routesStart = CFAbsoluteTimeGetCurrent()
                routes = uniqueRoutes.compactMap { self.constructShortRoute(edges: $0) }
                let routesDiff = CFAbsoluteTimeGetCurrent() - routesStart
                debugPrint("route building time - \(routesDiff)")
                
                completion(.success(routes))
                DispatchQueue.global().async { [weak self] in
                    self?.graph.restore(edges: editedEdges)
                }
                let diff = CFAbsoluteTimeGetCurrent() - start
                debugPrint("took \(diff) secs")
            }
        }
    }
}

// MARK: – Private methods
extension MetroService {
    
    private func processEmergencies(with data: JSON) -> [Emergency] {
        var emergencies = [Emergency]()
        let emergenciesDTO = data["data"].arrayValue.map {
            return EmergencyDTO.map($0)
        }
        self.emergenciesDTO = emergenciesDTO
        for emergency in emergenciesDTO {
            emergencies.append(DTOMapper.map(emergency))
        }
        for emergency in emergencies {
            for connection in emergency.connections {
                switch connection.status {
                case .closed:
                    if let edgeForward = self.graph.findEdge(by: connection.id, isTransition: connection.isTransition), let edgeBackward = self.graph.findEdge(by: connection.id + 1000, isTransition: connection.isTransition) {
                        self.graph.remove(edge: edgeForward)
                        self.graph.remove(edge: edgeBackward)
                    }
                case .closedForward:
                    if let edgeForward = self.graph.findEdge(by: connection.id, isTransition: connection.isTransition) {
                        self.graph.remove(edge: edgeForward)
                    }
                case .closedBackward:
                    if let edgeBackward = self.graph.findEdge(by: connection.id + 1000, isTransition: connection.isTransition) {
                        self.graph.remove(edge: edgeBackward)
                    }
                }
            }
            for alternative in emergency.alternativeConnections {
                if let vertexFrom = self.graph.vertex(by: alternative.stationFromID), let vertexTo = self.graph.vertex(by: alternative.stationToID) {
                    self.graph.add(id: alternative.id, .directed, from: vertexFrom, to: vertexTo, weight: alternative.weight, isTransition: false)
                }
            }
        }
        return emergencies
    }
    
    typealias EdgeSection = (edges: [Edge], isTransfer: Bool, isMCD: Bool)
    
    private func calculateCost(edges: [Edge]) -> Int {
        let outside = edges.filter { $0.source.isOutside || $0.destination.isOutside }
        if outside.isEmpty {
            return 42
        } else {
            return 50
        }
    }
    
    private func constructShortRoute(edges: [Edge]) -> ShortRoute? {
        var from: Station? = nil
        var to: Station? = nil
        guard let mapper = mapper else { return nil }
        if let firstID = edges.first?.source.id,
           let lastID  = edges.last?.destination.id,
           let fromDTO = self.get(by: firstID), // realmContext.fetch(StationDTO.self, primaryKey: firstID),
           let toDTO   = self.get(by: lastID), // realmContext.fetch(StationDTO.self, primaryKey: lastID),
           let _from   = mapper.map(dto: fromDTO),
           let _to     = mapper.map(dto: toDTO) {
            from = _from
            to = _to
        }
        let metadata = RouteMetadata(totalTime: edges.reduce(0, { x, y in
            x + y.weight
        }), transfers: edges.filter { $0.isTransition }.count ,
        cost: calculateCost(edges: edges))
        guard let routeDraw = routeDrawData(from: edges) else { return nil }
        return ShortRoute(metadata: metadata, from: from, to: to, drawMetadata: routeDraw, edges: edges)
    }
    
    public func constructRoute(from shortRoute: ShortRoute) -> FullRoute? { //тут все эджи
        
        var ids = [Int]()
        shortRoute.edges.enumerated().forEach { (index, element) in
            if index == 0 {
                ids.append(contentsOf: [element.source.id,element.destination.id])
            } else {
                ids.append(element.destination.id)
            }
        }
        let matchingEmergencies = self.emergencies.filter { $0.stations.contains(where: {  ids.contains($0.id)})}
        let groupedEdges = group(shortRoute.edges)
        let enterTime = Double(shortRoute.from?.enterTime ?? 0)
        let exitTime = Double(shortRoute.to?.exitTime ?? 0)
        
        var sections = [Any]()
        
        //перебираем сгруппированные эджи по линиям
        for (index,section) in groupedEdges.enumerated() {
            if section.isTransfer {
                makeTransferSection(section.edges[0], sections: &sections, sectionIndex: index, sectionsEndIndex: groupedEdges.endIndex)
                //sections.append(transferSection)
            } else {
                guard let lineSection = makeLineSection(section.edges) else { return nil }
                sections.append(lineSection)
            }
        }
        
        if groupedEdges.contains(where: { $0.isMCD }) {
            insertValidation(&sections)
        }
        
        sections.insert(EntrySection(totalTime: enterTime, type: .enter), at: 0)
        sections.insert(EntrySection(totalTime: exitTime, type: .exit), at: sections.endIndex)
        
        return FullRoute(metadata: shortRoute.metadata, from: shortRoute.from, to: shortRoute.to, sections: sections, emergencies: matchingEmergencies)
        
    }
    
    private func checkPayment(index: Int, endIndex: Int, paid: inout Int?, section: Any, includingLast: Bool) -> Int? {
        
        if endIndex == 1 {
            if let line = section as? LineSection, let firstStop = line.stops.first, let lastStop = line.stops.last {
                if paid == nil {
                    paid = firstStop.isOutside ? 50 : 42
                    return paid
                } else {
                    if paid == 42 {
                        paid = lastStop.isOutside ? 8 : nil
                        return paid
                    } else {
                        return nil
                    }
                }
            }
            if let singleStop = section as? SingleStopSection {
                paid = singleStop.stop.isOutside ? 50 : 42
                return paid
            }
        }
        if index == 0 {
            if let line = section as? LineSection, let firstStop = line.stops.first, let lastStop = line.stops.last  {
                if includingLast {
                    return lastStop.isOutside ? 8 : nil
                }
                paid = firstStop.isOutside ? 50 : 42
                return paid
            }
            
            if let singleStop = section as? SingleStopSection {
                if includingLast {
                    return singleStop.stop.isOutside ? 8 : nil
                }
                paid = singleStop.stop.isOutside ? 50 : 42
                return paid
            }
        }
        if index == endIndex - 1 {
            if let line = section as? LineSection, let firstStop = line.stops.first, let lastStop = line.stops.last {
                if includingLast {
                    if let _paid = paid {
                        if _paid == 42 {
                            return lastStop.isOutside ? 8 : nil
                        } else {
                            return nil
                        }
                    }
                    
                }
                if let _paid = paid {
                    if _paid == 42 {
                        return firstStop.isOutside ? 8 : nil
                    }
                }
            }
            if let singleStop = section as? SingleStopSection {
                if let _paid = paid {
                    if _paid == 42 {
                        return singleStop.stop.isOutside ? 8 : nil
                    }
                }
            }
        }
        return nil
    }
    
    /// Вставляет в итоговые секции маршрута валидацию
    /// - Parameter routeSections: секции маршрута
    private func insertValidation(_ routeSections: inout [Any]) {
        // создаем копию секций для грамотной вставки
        var newSections = routeSections
        // платил ли пассажир или нет
        var paid: Int? = nil
        // валидировался ли уже пассажир по метро
        var alreadyValidatedInMetro = false
        
        
        for (index,section) in routeSections.enumerated() {
            switch section {
            case is LineSection:
                let lineSection = section as! LineSection
                // ищем индекс этого элемент в нашей копии (чтобы корректно вставить валидацию
                guard let indexOfLine = newSections.firstIndex(where: {
                    if let _section = $0 as? LineSection {
                        if _section == lineSection {
                            return true
                        }
                    }
                    return false
                }) else { return }
                
                // Если секция = МЦД
                if lineSection.stops.contains(where: { $0.isMCD }) {
                    // вставляем входную валидацию
                    newSections.insert(ValidationSection(type: .entryPayment(checkPayment(index: index, endIndex: routeSections.endIndex, paid: &paid, section: section, includingLast: false))), at: indexOfLine)
                    // вставляем валидацию на выход
                    newSections.insert(ValidationSection(type: .exitPayment(checkPayment(index: index, endIndex: routeSections.endIndex, paid: &paid, section: section, includingLast: true))), at: indexOfLine+2)
                    // Если секция = МЦК, правило важное – для мцк всегда нужна входная валидация
                } else if lineSection.stops.contains(where: { $0.isMCC }) {
                    // вставляем входную валидацию
                    newSections.insert(ValidationSection(type: .entryPayment(checkPayment(index: index, endIndex: routeSections.endIndex, paid: &paid, section: section, includingLast: false))), at: indexOfLine)
                }
                // Если секция = Метро
                else {
                    // если чел уже валидировался в метро, то валидации не нужны
                    if !alreadyValidatedInMetro {
                        newSections.insert(ValidationSection(type: .entryPayment(checkPayment(index: index, endIndex: routeSections.endIndex, paid: &paid, section: section, includingLast: false))), at: indexOfLine)
                        alreadyValidatedInMetro = true
                    }
                    
                }
            case is SingleStopSection:
                let singleStopSection = section as! SingleStopSection
                // ищем индекс этого элемент в нашей копии (чтобы корректно вставить валидацию
                guard let indexOfSection = newSections.firstIndex(where: {
                    if let _section = $0 as? SingleStopSection {
                        if _section == singleStopSection {
                            return true
                        }
                    }
                    return false
                }) else { return }
                
                if singleStopSection.stop.isMCD {
                    newSections.insert(ValidationSection(type: .entryPayment(checkPayment(index: index, endIndex: routeSections.endIndex, paid: &paid, section: section, includingLast: false))), at: indexOfSection)
                    newSections.insert(ValidationSection(type: .exitPayment(checkPayment(index: index, endIndex: routeSections.endIndex, paid: &paid, section: section, includingLast: true))), at: indexOfSection+2)
                } else {
                    newSections.insert(ValidationSection(type: .entryPayment(checkPayment(index: index, endIndex: routeSections.endIndex, paid: &paid, section: section, includingLast: false))), at: indexOfSection)
                }
            default:
                break
            }
        }
        
        routeSections = newSections
    }
    
    
    private func routeDrawData(from edges: [Edge]) -> RouteDrawMetadata? {
        var transitionsKeys = [String]()
        var connectionsKeys = [String]()
        var textsKeys = [String]()
        var stationsKeys = [String]()
        
        for (index,edge) in edges.enumerated() {
            var edgeID = edge.id
            if !(edgeID > 3000) {
                edgeID = edge.id > 1000 ? edge.id - 1000 : edge.id
            }
            
            
            
            
            if edge.isTransition {
                transitionsKeys.append("transition-\(edgeID)")
                //textsKeys.append("station-caption-\(edge.destination.id)")
            } else {
                connectionsKeys.append("connection-\(edgeID)")
            }
            
            stationsKeys.append("station-\(edge.source.id)")
            textsKeys.append("caption-\(edge.source.id)")
            if index == edges.endIndex - 1 {
                stationsKeys.append("station-\(edge.destination.id)")
                textsKeys.append("caption-\(edge.destination.id)")
            }
        }
        guard let first = edges.first?.source, let last = edges.last?.destination else { return nil }
        return RouteDrawMetadata(stationKeys: stationsKeys,
                                 connectionKeys: connectionsKeys,
                                 transfersKeys: transitionsKeys,
                                 textsKeys: textsKeys,
                                 fromCoordinate: MapPoint(x: first.x, y: first.y),
                                 toCoordinate: MapPoint(x: last.x, y: last.y))
        
    }
    
    private func makeTransferSection(_ edge: Edge, sections: inout [Any], sectionIndex: Int, sectionsEndIndex: Int) {
        guard let mapper = self.mapper else { return }
        guard let transitionDTO = self.transitionsDTO.filter({ $0.id == edge.id }).first,
              let fromDTO       = transitionDTO.from,
              let toDTO         = transitionDTO.to,
              let stationFrom   = mapper.map(dto: fromDTO),
              let stationTo     = mapper.map(dto: toDTO) else { return }
        if let lastSection = sections[safe: sections.endIndex - 1] as? LineSection, let lastStop = lastSection.stops[safe: lastSection.stops.endIndex - 2] {
            let filtered = transitionDTO.wagons.filter { $0.prevStationID == lastStop.id }
            if let first = filtered.first {
                sections[sections.endIndex - 1] = LineSection(stops: lastSection.stops,
                                                              line: lastSection.line,
                                                              direction: lastSection.direction, directionID: lastSection.directionID,
                                                              totalTime: lastSection.totalTime,
                                                              wagons: first.types.compactMap { Wagons(rawValue: $0) })
            }
            sections.append(TransferSection(totalTime: transitionDTO.weight, videoURL: transitionDTO.pathVideoURL == "no" ? nil : transitionDTO.pathVideoURL))
            if sectionIndex == sectionsEndIndex - 1 {
                let singleStopSection = SingleStopSection(stop: stationTo)
                sections.append(singleStopSection)
            }
        } else {
            let singleStopSection = SingleStopSection(stop: stationFrom)
            sections.append(singleStopSection)
            sections.append(TransferSection(totalTime: transitionDTO.weight, videoURL: transitionDTO.pathVideoURL == "no" ? nil : transitionDTO.pathVideoURL))
            if sectionIndex == sectionsEndIndex - 1 {
                let singleStopSection = SingleStopSection(stop: stationTo)
                sections.append(singleStopSection)
            }
        }
    }
    
    private func makeLineSection(_ edges: [Edge]) -> LineSection? {
        var stops = [Station]()
        guard let mapper = self.mapper else { return nil}
        for (index,edge) in edges.enumerated() {
            if index == edges.endIndex - 1 {
                guard let stationDTO = self.get(by: edge.source.id),
                      let lastStationDTO = self.get(by: edge.destination.id),
                      let station = mapper.map(dto: stationDTO),
                      let lastStation = mapper.map(dto: lastStationDTO) else { return nil }
                stops.append(contentsOf: [station,lastStation])
            } else {
                guard let station = self.stations.filter({ $0.id == edge.source.id }).first else { return nil }
                stops.append(station)
            }
        }
        guard let firstStop = stops.first,
              let firstLineStationDTO = self.stationsDTO.values.filter({ $0.line?.firstStationID == firstStop.line.firstStationID }).first,
              let firstLineStation = mapper.map(dto: firstLineStationDTO),
              let lastLineStationDTO = self.stationsDTO.values.filter({ $0.line?.lastStationID == firstStop.line.lastStationID }).first,
              let lastLineStation = mapper.map(dto: lastLineStationDTO)
        else { return nil }
        var towards = ""
        var directionID = 0
        if let secondStop = stops[safe: 1] {
            towards = firstStop.ordering < secondStop.ordering ? String.localizedStringWithFormat(NSLocalizedString("Towards %@", tableName: nil, bundle: .mm_Map, value: "", comment: ""), lastLineStation.name) : String.localizedStringWithFormat(NSLocalizedString("Towards %@", tableName: nil, bundle: .mm_Map, value: "", comment: ""), firstLineStation.name)
            directionID = firstStop.ordering < secondStop.ordering ? lastLineStation.id : firstLineStation.id
            // если первая станция - последняя а следующаая - первая
            if (firstStop.ordering < secondStop.ordering) ||
                (firstStop.line.id ==  6 && firstStop.ordering == 12 && stops[1].ordering == 1) ||
                (firstStop.line.id == 16 && firstStop.ordering == 31 && stops[1].ordering == 1) {
                if let prompt = lastLineStationDTO.line?.lastStationPrompt {
                    towards = "\(prompt) \(towards)"
                }
            } else {
                if let prompt = firstLineStationDTO.line?.firstStationPrompt {
                    towards = "\(prompt) \(towards)"
                }
            }
        }
        return LineSection(stops: stops, line: firstStop.line , direction: towards, directionID: directionID , totalTime: edges.reduce(0, { x,y in
            x + y.weight
        }), wagons: [])
    }
    
    private func group(_ edges: [Edge]) -> [EdgeSection]{
        var groupedEdges = [EdgeSection]()
        var temp = [Edge]()
        for edge in edges {
            if edge.isTransition {
                if !temp.isEmpty {
                    guard let first = temp.first, let last = temp.last else { continue }
                    let isMCD = first.source.isMCD || last.destination.isMCD
                    groupedEdges.append((edges: temp, isTransfer: false, isMCD: isMCD))
                }
                temp = []
                let isMCD = edge.destination.isMCD || edge.source.isMCD
                groupedEdges.append((edges: [edge], isTransfer: true, isMCD: isMCD))
            } else {
                temp.append(edge)
            }
        }
        if !temp.isEmpty {
            guard let first = temp.first, let last = temp.last else { return [] }
            let isMCD = first.source.isMCD && last.destination.isMCD
            groupedEdges.append((edges: temp, isTransfer: false, isMCD: isMCD))
        }
        return groupedEdges
    }
    
    private func pifagorHeuristic(_ s: Vertex, _ t: Vertex) -> Double {
        return sqrt(abs(s.x - t.x) + abs(s.y - t.y))
    }
    
    //D * (dx + dy) + (D2 - 2 * D) * min(dx, dy)
    private func testHeuristic(_ s: Vertex, _ t: Vertex) -> Double {
        let dx = abs(s.x - t.x)
        let dy = abs(s.y - t.y)
        return max(dx,dy) + 0.41 * min(dx,dy)
        //return sqrt(abs(s.x - t.x) + abs(s.y - t.y))
    }
    
    public func buildGraph(_ includingFutureElements: Bool) {
        let start = CFAbsoluteTimeGetCurrent()                      //Засекаем время
        self.graph.adjacencyDict.removeAll()                        //Строим граф всё время с нуля
        var texts = [String: TextDrawingData]()                     //Для слов на карте
        var stationsGraphics = [String: Any]()                      //Для станций?
        var connectionsGraphics = [String: Any]()                   //Для соединений
        var transitionsGraphics = [String: GradientDrawingData]()   //Для Переходов
        let additional = [AdditionalDrawindData]()                  //Дополнительные вещи
        
        for stationDTO in self.stationsDTO.values {
            self.coordinates.updateValue(MapPoint(latitude: stationDTO.latitude, longitude: stationDTO.longitude), forKey: stationDTO.id)
            self.graph.createVertex(id: stationDTO.id, x: stationDTO.x, y: stationDTO.y, isMCD: stationDTO.isMCD, isOutside: stationDTO.isOutside, isMCC: stationDTO.isMCC)
            guard let graphics = stationDTO.graphics, let tapGrid = graphics.tapGrid, let textData = graphics.text else { continue }
            self.tapGrids.updateValue(CGRect(x: tapGrid.x, y: tapGrid.y, width: tapGrid.w, height: tapGrid.h), forKey: stationDTO.id)
            texts.updateValue(TextDrawingData(frame: CGRect(x: textData.x, y: textData.y, width: textData.w, height: textData.h + 15), text: Localize.currentLanguage() == "ru" ? stationDTO.name_ru : stationDTO.name_en), forKey: "caption-\(stationDTO.id)")
            if let parsed = GraphicsUtils.parsePath(name: "station-\(stationDTO.id)", svgString: graphics.mainSVG) {
                stationsGraphics.updateValue(parsed, forKey: "station-\(stationDTO.id)")
            }
        }
        
        for edge in self.connectionsDTO {
            guard let fromID = edge.from?.id,
                  let toID = edge.to?.id,
                  let vertexFrom = self.graph.vertex(by: fromID),
                  let vertexTo = self.graph.vertex(by: toID)
            else { continue }
            
            self.graph.add(id: edge.id,
                           .directed,
                           from: vertexFrom,
                           to: vertexTo,
                           weight: edge.weight,
                           isTransition: false)
            connectionsGraphics.updateValue(GraphicsUtils.parsePath(name: "connection-\(edge.id)", svgString: edge.svg) as Any, forKey: "connection-\(edge.id)")
        }
        
        for edge in self.transitionsDTO {
            guard let fromID = edge.from?.id,
                  let toID = edge.to?.id,
                  let vertexFrom = self.graph.vertex(by: fromID),
                  let vertexTo = self.graph.vertex(by: toID)
            else { continue }
            
            self.graph.add(id: edge.id,
                           .directed,
                           from: vertexFrom,
                           to: vertexTo,
                           weight: edge.weight,
                           isTransition: true)
            if let element = try? SVGParser.parse(text: "<svg>\(edge.svg)</svg>"), let rect = element.bounds?.toCG() {
                let image = element.toNativeImage(size: Size(Double(rect.width * UIScreen.main.scale), Double(rect.height * UIScreen.main.scale)))
                guard let cgImage = image.cgImage else { continue }
                //                guard MTIImage(cgImage: cgImage) != nil else { continue }
                transitionsGraphics.updateValue(GradientDrawingData(cgImage: cgImage, frame: rect), forKey: "transition-\(edge.id)")
            }
        }
        
        self.mapDrawingOptions = MapDrawingOptions(stations: stationsGraphics, connections: connectionsGraphics, transitions: transitionsGraphics, captions: texts, mapSize: CGSize(width: self.mapSizeDto.width, height: self.mapSizeDto.height), addtional: additional)
        let diff = CFAbsoluteTimeGetCurrent() - start  // Конец засечённому времени
        debugPrint("took \(diff) secs to make graph")
    }
}

