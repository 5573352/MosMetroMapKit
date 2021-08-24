//
//  RouteDetailsController.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 28.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit
import SPAlert
import SwiftDate
import FloatingPanel

struct WagonSection   : Hashable {
    let sectionIndex : Int
    let directionID  : Int
    let color        : UIColor
    let station      : Station
    
    static func == (lhs: WagonSection, rhs: WagonSection) -> Bool {
        return lhs.station.id == rhs.station.id
    }
}

/// Enum of state positions BasePanelController
///
/// - **modal**             is the classic position as modal view
/// - **all**                    contains 3 positions: modal, half and tip
/// - **modalCenter**  contains 2 position: modal and half
/// - **fullScreen**       the controller is displayed in full screen
/// - **guideLayout**  positions for GuideController
public enum AnchorPosition {
    case modal
    case all
    case modalCenter
    case fullScreen
    case guideLayout
}


public enum TypeDevices {
    case oldModels
    case newModels
    case allModels
}

// MARK: - Devices fabrica
/// This structure contains a method that returns an array of mobile device names
public struct DevicesFabrica {
    
    /**
     This method returns an array of mobile device names
     
     - Parameters:
       - type: devices type
     - Returns: array of mobile device names
     */
    static func get(with type: TypeDevices) -> [String] {
        switch type {
        case .newModels :
            return ["iPhone 6", "iPhone 6s", "iPhone 7",
                    "iPhone 8", "iPod touch (6th generation)", "iPod touch (7th generation)",
                    /*"Simulator iPhone 6", "Simulator iPhone 6s", "Simulator iPhone 7",
                    "Simulator iPhone 8", "Simulator iPod touch (6th generation)", "Simulator iPod touch (7th generation)"*/]
        case .oldModels :
            return ["iPhone 5c", "iPhone 5s", "iPhone SE",
                  /*  "Simulator iPhone 5c", "Simulator iPhone 5s", "Simulator iPhone SE"*/]
        case .allModels :
            return ["iPhone 5c", "iPhone 5s", "iPhone SE",
                    "iPhone 6" , "iPhone 6s", "iPhone 7",
                    "iPhone 8", "iPod touch (6th generation)", "iPod touch (7th generation)",
                   /* "Simulator iPhone 5c", "Simulator iPhone 5s", "Simulator iPhone SE",
                    "Simulator iPhone 6" , "Simulator iPhone 6s", "Simulator iPhone 7",
                    "Simulator iPhone 8" , "Simulator iPod touch (6th generation)", "Simulator iPod touch (7th generation)" */]
        }
    }
    
    private init() {}
}

// MARK: - BasePanelLayout
/// An interface for generating layout information for a panel
class BasePanelLayout: FloatingPanelLayout {
    
    //MARK: - Properties
    let position     : FloatingPanelPosition = .bottom
    var initialState : FloatingPanelState
    var anchors      : [FloatingPanelState : FloatingPanelLayoutAnchoring] = [:]
    
    /// Initialization with setting the starting position and case of states for panel acnhors
    /// - Parameters:
    ///   - state:    the initial state when a panel is presented
    ///   - position: case anchors positions for the panel
    init(state: FloatingPanelState = .full, position: AnchorPosition) {
        initialState = state
        self.anchors = getAnchors(position)
    }
    
    /// Anchor position generation method depending on the model of the mobile device
    /// - Parameter position: - case contains of state positions BasePanelController
    /// - Returns: achor position in depending on the model of the mobile device
    private func getAnchors(_ position: AnchorPosition) ->  [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        
        switch position {
        case .modal         :
            var newAnchor: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
                return [
                    .full : FloatingPanelLayoutAnchor(absoluteInset: 16, edge: .top, referenceGuide: .safeArea)
                ]
            }
            return newAnchor
        case .modalCenter     :
            switch UIDevice.modelName {
            case let device where DevicesFabrica.get(with: .allModels).contains(device) :
                var newAnchor: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
                    return [
                        .full   : FloatingPanelLayoutAnchor(absoluteInset:     32, edge: .top,    referenceGuide: .safeArea  ),
                        .half   : FloatingPanelLayoutAnchor(fractionalInset: 0.45, edge: .bottom, referenceGuide: .superview )
                    ]
                }
                return newAnchor
            default:
                var newAnchor: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
                    return [
                        .full   : FloatingPanelLayoutAnchor(absoluteInset:     32, edge: .top,    referenceGuide: .safeArea  ),
                        .half   : FloatingPanelLayoutAnchor(fractionalInset: 0.45, edge: .bottom, referenceGuide: .superview )
                    ]
                }
                return newAnchor
            }
        case .all           :
            switch UIDevice.modelName {
            case let device where DevicesFabrica.get(with: .oldModels).contains(device) :
                var newAnchor: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
                    return [
                        .full   : FloatingPanelLayoutAnchor(absoluteInset   : 32,   edge: .top,    referenceGuide: .safeArea  ),
                        .half   : FloatingPanelLayoutAnchor(fractionalInset : 0.55, edge: .bottom, referenceGuide: .superview ),
                        .tip    : FloatingPanelLayoutAnchor(absoluteInset   : 92,   edge: .bottom, referenceGuide: .safeArea  )
                    ]
                }
                return newAnchor
            case let device where DevicesFabrica.get(with: .newModels).contains(device) :
                var newAnchor: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
                    return [
                        .full   : FloatingPanelLayoutAnchor(absoluteInset   : 32,  edge: .top,    referenceGuide: .safeArea   ),
                        .half   : FloatingPanelLayoutAnchor(fractionalInset : 0.5, edge: .bottom, referenceGuide: .superview  ),
                        .tip    : FloatingPanelLayoutAnchor(absoluteInset   : 92,  edge: .bottom, referenceGuide: .safeArea   )
                    ]
                }
                return newAnchor
            default:
                var newAnchor: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
                    return [
                        .full   : FloatingPanelLayoutAnchor(absoluteInset   : 32,   edge: .top,    referenceGuide: .safeArea  ),
                        .half   : FloatingPanelLayoutAnchor(fractionalInset : 0.45, edge: .bottom, referenceGuide: .superview ),
                        .tip    : FloatingPanelLayoutAnchor(absoluteInset   : 92,   edge: .bottom, referenceGuide: .safeArea  )
                    ]
                }
                return newAnchor
            }
        case .fullScreen    :
            var newAnchor: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
                return [
                    .full: FloatingPanelLayoutAnchor(fractionalInset: 0, edge: .top, referenceGuide: .superview ),
                ]
            }
            return newAnchor
        case .guideLayout :
            switch UIDevice.modelName {
            case let device where DevicesFabrica.get(with: .allModels).contains(device) :
                var newAnchor: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
                    return [
                        .half: FloatingPanelLayoutAnchor(fractionalInset: 0.45, edge: .bottom, referenceGuide: .superview ),
                    ]
                }
                return newAnchor
            default:
                var newAnchor: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
                    return [
                        .half: FloatingPanelLayoutAnchor(fractionalInset: 0.4, edge: .bottom, referenceGuide: .superview  )
                    ]
                }
                return newAnchor
            }
        }
    }
}



class BasePanelController : FloatingPanelController {
    
    ///  Initialization with setting the starting position and case of states for panel acnhors
    /// - Parameters:
    ///   - contentVC: view controller responsible for the content portion of a panel
    ///   - positions:         case anchors positions for the panel
    ///   - state:                the initial state when a panel is presented
    init(contentVC: UIViewController?, positions: AnchorPosition, state: FloatingPanelState = .half) {
        super.init(delegate: nil)
        guard contentVC != nil else { return }
        isRemovalInteractionEnabled = true
        layout                      = BasePanelLayout(state: state, position: positions)
        setupSurface()
        set(contentViewController: contentVC)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: - Surface Background Color
    private func setupSurface() {
        surfaceView.backgroundColor = .clear
        surfaceView.appearance      = FloatingPanelController.metroAppereance()
    }
    
}

class RouteDetailsController: BaseController {
    
    private let service = NetworkService()
    
    weak var metroService: MetroService?
    
    private var trainsWorkloadSectionIndex: Int?

    public var timer: Timer!
    
    @objc
    private func loadTrains() {
        workload.forEach { (key,value) in
            guard let service = self.metroService else { return }
            let all = Array(service.stationsDTO.values)
            self.service.trainsWorkload(by: key.station, all: all, callback: { [weak self] result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self?.workload.updateValue(data, forKey: key)
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self?.workload.updateValue(nil, forKey: key)
                    }
                }
            })
        }
    }
    
    private func loadMCD() {
        schedule.forEach { (key,value) in
            MCDSchedule.loadSchedule(by: key.station.id, callback: { [weak self] result in
                switch result {
                case .success(let data):
                    self?.schedule.updateValue(data, forKey: key)
                case .failure(_):
                    self?.schedule.updateValue(nil, forKey: key)
                }
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
//        timer.invalidate()
//        timer = nil
    }
    
    private func initialLoadTrains() {
        self.timer = nil
        let currentSecond = Date().second
        let fireAfterSecond = (10 - (currentSecond % 10)) + 2
        print("FIRE AFTER = \(fireAfterSecond)")
        self.loadTrains()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(fireAfterSecond), target: self, selector: #selector(loadTrains), userInfo: nil, repeats: false)
        
        RunLoop.current.add(self.timer, forMode: RunLoop.Mode.common)
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(fireAfterSecond), execute: { [weak self] in
            guard let self = self else { return }
            if let _timer = self.timer { _timer.invalidate() }
            self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.loadTrains), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer, forMode: RunLoop.Mode.common)
        })
    }
    
    private var workload: [WagonSection: TrainWorkload?] = [:] {
        didSet {
            workload.forEach { [weak self] in
                self?.setWorkloadState(workload: $0.value, sectionData: $0.key)
            }
        }
    }
    
    private var schedule: [WagonSection: MCDSchedule?] = [:] {
        didSet {
            schedule.forEach { [weak self] in
                self?.setSchedule(schedule: $0.value, section: $0.key)
            }
        }
    }
    
    private func setWorkloadState(workload: TrainWorkload?, sectionData: WagonSection) {
        if let workload = workload {
            for wayData in workload.wayData {
                if wayData.towardsStationID == sectionData.directionID {
                    let trains = wayData.data.map {
                        return LineLoadWagonsTableViewCell.ViewState(color: sectionData.color,
                                                                     arrivalTime: $0.arrivalTime,
                                                                     onSelect: {},
                                                                     wagons: $0.wagonsWorkload.map { LineLoadWagonsTableViewCell.ViewState.Load(rawValue: $0.rawValue)!  },
                                                                     isStanding: $0.status == .standing ? true : false)
                    }
                    let infoWagonRows = RouteDetailsView.ViewState.InfoWagonLoad(color: sectionData.color, info: NSLocalizedString("Nearest trains and workload", tableName: nil, bundle: .mm_Map, value: "", comment: ""))
                    let lastUpdate = RouteDetailsView.ViewState.LastUpdateWagonLoad(color: sectionData.color, lastUpdate: "\(NSLocalizedString("Last update – ", tableName: nil, bundle: .mm_Map, value: "", comment: ""))\(Date().dateByAdding(3, .hour).toFormat("HH:mm:ss"))")
                    if self.routeDetailsView.viewState.sections[safe: sectionData.sectionIndex] != nil {
                        var rows = [Any]()
                        rows.append(infoWagonRows)
                        rows.append(contentsOf: trains)
                        rows.append(lastUpdate)
                        self.routeDetailsView.viewState.sections[sectionData.sectionIndex].rows = rows
                        UIView.performWithoutAnimation({
                            self.routeDetailsView.tableView.reloadSections([sectionData.sectionIndex], with: .none)
                        })
                    }
                }
            }
        } else {
            if self.routeDetailsView.viewState.sections[safe: sectionData.sectionIndex] != nil {
                self.routeDetailsView.viewState.sections[sectionData.sectionIndex].rows = []
                UIView.performWithoutAnimation({
                    self.routeDetailsView.tableView.reloadSections([sectionData.sectionIndex], with: .none)
                })
            }
        }
    }
    
    var route: ShortRoute! {
        didSet {
            self.routeDetailsView.state = .loading
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                if let fullRoute = self.metroService?.constructRoute(from: self.route) {
                    DispatchQueue.main.async {
                        self.routeDetailsView.viewState = self.makeState(from: fullRoute)
                        self.routeDetailsView.state = .loaded
                    }
                }
            }
        }
    }
    
    var index = 0
    
    public let routeDetailsView = RouteDetailsView(frame: UIScreen.main.bounds)

    private func mcdStatus(status: MCDStatus) -> MCDArrivaleCollectionViewCell.ViewState.Status {
        switch status {
        case .late(_):
            return .late
        case .early(_):
            return .early
        case .standart:
            return .standart
        }
    }
    
    private func setSchedule(schedule: MCDSchedule?, section: WagonSection) {
        if let schedule = schedule {
            let data = section.directionID == section.station.line.firstStationID ? schedule.start : schedule.end
            if let three = MCDThread.getNearestThree(threads: data) {
                var rows = [Any]()
                let infoRow = RouteDetailsView.ViewState.MCDInfoWagonLoad(color: section.station.line.color, info: NSLocalizedString("Nearest trains", tableName: nil, bundle: .mm_Map, value: "", comment: ""))
                let items: [MCDNearestTrainCell.ViewState] = three.map { item in
                    var detailsText = "№\(item.trainNum)"
                    if let platform = item.platform {
                        detailsText = detailsText + " • \(NSLocalizedString("pl.", tableName: nil, bundle: .mm_Map, value: "", comment: ""))\(platform) "
                    }
                    return MCDNearestTrainCell.ViewState(color: section.station.line.color, arrivalTime: item.getArrivalString(), onSelect: {}, isStanding: false, details: detailsText)
                }
                let lastUpdateRow = RouteDetailsView.ViewState.MCDLastUpdateWagonLoad(color: section.station.line.color, lastUpdate: "\( NSLocalizedString("Last update – ", tableName: nil, bundle: .mm_Map, value: "", comment: ""))\(Date().dateByAdding(3, .hour).toFormat("HH:mm:ss"))")
                rows.append(infoRow)
                rows.append(contentsOf: items)
                rows.append(lastUpdateRow)
                if self.routeDetailsView.viewState.sections[safe: section.sectionIndex] != nil {
                    self.routeDetailsView.viewState.sections[section.sectionIndex].rows = rows
                    DispatchQueue.main.async {
                        UIView.performWithoutAnimation({
                            self.routeDetailsView.tableView.reloadSections([section.sectionIndex], with: .none)
                        })
                    }
                }
            }
        } else {
            if self.routeDetailsView.viewState.sections[safe: section.sectionIndex] != nil {
                self.routeDetailsView.viewState.sections[section.sectionIndex].rows = []
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation({
                        self.routeDetailsView.tableView.reloadSections([section.sectionIndex], with: .none)
                    })
                }
            }
        }
    }
    
    private func handleMCDRouteTap(thread: MCDThread, isFromSchedule: Bool) {
//        let routeVC = MCDRouteScreen()
//        let routeControllerFPC = BasePanelController(contentVC: routeVC, positions: .modal, state: .full)
//        self.present(routeControllerFPC, animated: true, completion: nil)
//       
//        routeVC.idtr = thread.idtr
//        //routeVC.titleLabel.text = "Route".localized() + " \("№\(thread.trainNum)")"  //Название маршрута сюда
//        routeControllerFPC.track(scrollView: routeVC.tableView)
    }
}

extension RouteDetailsController {
    
    private func makeState(from fullRoute: FullRoute) -> RouteDetailsView.ViewState {
        var timeForStations: TimeInterval = 0
        var tableSections = [Section]()
        if !fullRoute.emergencies.isEmpty {
            let onSelect = { [weak self] in
                guard let self = self else { return}
                let vc = RouteEmergenciesController()
                let panel = BasePanelController(contentVC: vc, positions: .modal, state: .full)
                self.present(panel, animated: true, completion: nil)
                vc.model = fullRoute.emergencies
                panel.track(scrollView: vc.tableView)
            }
            let emergenciesRow = RouteDetailsView.ViewState.EmergencyData(onSelect: onSelect)
            tableSections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [emergenciesRow], onExpandTap: nil))
        }
        for section in fullRoute.sections {
            switch section {
            //MARK: - SingleStopSection
            case is SingleStopSection:
                let data = section as! SingleStopSection
                let singleStopData = RouteDetailsView.ViewState.SingleStopCell(name: data.stop.line.name, lineIcon: data.stop.line.originalIcon, firstStation: (name: data.stop.name, color: data.stop.line.color), isOutlined: data.stop.isMCC || data.stop.isMCD ? true : false, timeToStop: Utils.getTimeFromNow(timeForStations))
                 tableSections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [singleStopData], onExpandTap: nil))
            //MARK: - ValidationSection
            case is ValidationSection:
                let data = section as! ValidationSection
                switch data.type {
                case .entryPayment(let val):
                    let price = val != nil ? String.localizedStringWithFormat(NSLocalizedString("Pay %@", tableName: nil, bundle: .mm_Map, value: "", comment: ""), "\(val!) ₽") : NSLocalizedString("No payment", tableName: nil, bundle: .mm_Map, value: "", comment: "")
                    
                    let row = RouteDetailsView.ViewState.ValidationData(image: #imageLiteral(resourceName: "validation_entry"), price: price, title: NSLocalizedString("Entry validation", tableName: nil, bundle: .mm_Map, value: "", comment: ""))
                    tableSections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [row], onExpandTap: nil))
                    
                case .exitPayment(let val):
                    let price = val != nil ? String.localizedStringWithFormat(NSLocalizedString("Pay %@", tableName: nil, bundle: .mm_Map, value: "", comment: ""), "\(val!) ₽") : NSLocalizedString("No payment", tableName: nil, bundle: .mm_Map, value: "", comment: "")
                    let row = RouteDetailsView.ViewState.ValidationData(image: #imageLiteral(resourceName: "validation_exit"), price: price, title: NSLocalizedString("Exit vaildation", tableName: nil, bundle: .mm_Map, value: "", comment: ""))
                    tableSections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [row], onExpandTap: nil))
                }
            //MARK: - EntrySection
            case is EntrySection:
                let data = section as! EntrySection
                timeForStations += data.totalTime
                let timeStr = Utils.getTotalTime(data.totalTime)
                let entryData = RouteDetailsView.ViewState.EntryData(image: #imageLiteral(resourceName: "pedestrian_light"),
                                                                     text: data.type == .enter ? NSLocalizedString("Walk to the station", tableName: nil, bundle: .mm_Map, value: "", comment: "") : NSLocalizedString("Exit station", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
                                                                     time: timeStr)
                tableSections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [entryData], onExpandTap: nil))
            //MARK: - LineSection
            case is LineSection:
                let data = section as! LineSection
                let timeStr = Utils.getTotalTime(data.totalTime)
                var temp = data.stops
                let first = temp.removeFirst()
                let last = temp.removeLast()
                let lineData = RouteDetailsView.ViewState.LineSectionData(name: data.line.name,
                                                                          lineIcon: data.line.originalIcon,
                                                                          time: timeStr,
                                                                          direction: data.direction,
                                                                          wagon: data.wagons,
                                                                          advice: self.setAdvice(data.wagons),
                                                                          firstStation: (name: first.name, color: data.line.color),
                                                                          isOutlined: first.isMCC || first.isMCD ? true : false,
                                                                          timeToStop: Utils.getTimeFromNow(timeForStations))
                var stops = temp.map {
                    return RouteDetailsView.ViewState.StopData(stop: (name: $0.name, color: data.line.color), isOutlined: $0.isMCC || $0.isMCD ? true : false, timeToStop: "Error")
                }
                for k in 0 ..< stops.count {
                    timeForStations += route.edges[k].weight
                    stops[k].timeToStop = Utils.getTimeFromNow(timeForStations)
                }
                
                var lastStopData = RouteDetailsView.ViewState.LastStopData(stop: (name: last.name, color: data.line.color), isOutlined: last.isMCC || last.isMCD ? true : false)
                timeForStations += route.edges.last?.weight ?? 120
                lastStopData.timeToStop = Utils.getTimeFromNow(timeForStations)
                
                //TODO: ДОБАВИТЬ ПРОВЕРКУ НА КОЛИЧЕСТВО СТАНЦИЙ
                tableSections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [lineData], onExpandTap: nil))
                tableSections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [], onExpandTap: nil))
                if data.stops.first?.isMCD == true {
                    self.schedule.updateValue(nil, forKey: WagonSection(sectionIndex: tableSections.endIndex - 1, directionID: data.directionID, color: data.line.color, station: first))
                } else {
                    self.workload.updateValue(nil, forKey: WagonSection(sectionIndex: tableSections.endIndex - 1, directionID: data.directionID, color: data.line.color, station: first))
                }
                tableSections.append(Section(title: nil, isNeedToExpand: temp.count > 3, isExpanded:  !(temp.count > 3), rows: stops, onExpandTap: nil))
                tableSections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [lastStopData], onExpandTap: nil))
                
            //MARK: -TransferSection
            case is TransferSection:
                let data = section as! TransferSection
                timeForStations += data.totalTime
                let timeStr = Utils.getTotalTime(data.totalTime)
                let transferData = RouteDetailsView.ViewState.TransferData(image: #imageLiteral(resourceName: "pedestrian_light"),
                                                                           text: NSLocalizedString("Transfer", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
                                                                           time: timeStr)
                tableSections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [transferData], onExpandTap: nil))
            default:
                break
            }
        }
        initialLoadTrains()
        loadMCD()
        timeForStations = 0
        return RouteDetailsView.ViewState(sections: tableSections, totalTime: Utils.getTotalTime(route.metadata.totalTime),
                                          transfersAndCost: "\(String.localizedStringWithFormat(NSLocalizedString("transfers count", tableName: nil, bundle: .mm_Map, value: "", comment: ""), route.metadata.transfers)) • \(route.metadata.cost) ₽")
    }
    
    override func loadView() {
        super.loadView()
        view = routeDetailsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .navigationBar
    }
    
    private func setAdvice(_ wagons: [Wagons]) -> String {
        var suitableWagons = [String]()
        for wagon in wagons {
            switch wagon {
            case .all:
                suitableWagons.append(NSLocalizedString("all wagons are suitable", tableName: nil, bundle: .mm_Map, value: "", comment: ""))
            case .first:
                suitableWagons.append(NSLocalizedString("first wagon", tableName: nil, bundle: .mm_Map, value: "", comment: ""))
            case .nearFirst:
                suitableWagons.append(NSLocalizedString("closer to front", tableName: nil, bundle: .mm_Map, value: "", comment: ""))
            case .center:
                suitableWagons.append(NSLocalizedString("middle of train", tableName: nil, bundle: .mm_Map, value: "", comment: ""))
            case .nearEnd:
                suitableWagons.append(NSLocalizedString("closer to end", tableName: nil, bundle: .mm_Map, value: "", comment: ""))
            case .end:
                suitableWagons.append(NSLocalizedString("last wagon", tableName: nil, bundle: .mm_Map, value: "", comment: ""))
            }
        }
        return String.localizedStringWithFormat(NSLocalizedString("Get on %@", tableName: nil, bundle: .mm_Map, value: "", comment: ""), suitableWagons.map{String($0)}.joined(separator: ", "))
    }
}
