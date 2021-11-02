//
//  StationController.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 13.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class StationController: BasePanController {
    
    public var metroService : MetroService?
    private let service = NetworkService()
    
    public var onClose                 : (()->())?
    public var tipStationScreen        : (()->())?
    public var onEmergencyTap          : ((Station.Emergency)->())?
    public var onTransferStationSelect : ((Int,Station) -> ())?

    public var routeControllerFPC    : FloatingPanelController!
    public var scheduleControllerFPC : FloatingPanelController!
    
    private var diff = 0
    public var timer : Timer!

    private var actionsRowSectionIndex: Int?
    private var trainsWorkloadSectionIndex: Int?
    
    var isNeedToReload = true
    var stationView = StationView(frame: UIScreen.main.bounds)
    
    var mcdSchedule: MCDSchedule? {
        didSet {
            if let schedule = mcdSchedule {
                self.handleMCDSchedule(schedule)
            }
        }
    }
    
    var model: Station! {
        didSet {
            if model != nil {
                if timer != nil {
                    timer.invalidate()
                }
                timer = nil
                if isNeedToReload {
                    stationView.viewState = self.makeInitialState(from: model!)
                    stationView.tableView.reloadData()
                    isNeedToReload = false
                }
                if !self.model.isMCD {
                    let currentSecond = Date().second
                    let fireAfterSecond = (10 - (currentSecond % 10)) + 2
                    debugPrint("FIRE AFTER = \(fireAfterSecond)")
                    timer = Timer.scheduledTimer(timeInterval: TimeInterval(fireAfterSecond), target: self, selector: #selector(loadTrains), userInfo: nil, repeats: false)
                    RunLoop.current.add(self.timer, forMode: RunLoop.Mode.common)
                    self.loadTrains()
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(fireAfterSecond), execute: { [weak self] in
                        guard let self = self else { return }
                        if let _timer = self.timer {
                            _timer.invalidate()
                        }
                        self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.loadTrains), userInfo: nil, repeats: true)
                        RunLoop.current.add(self.timer, forMode: RunLoop.Mode.common)
                    })
                } else {
                    DispatchQueue.main.async {
                        self.loadSchedule()
                    }
                }
            }
        }
    }
    
    
    private func loadSchedule() {
        MCDSchedule.loadSchedule(by: model.id) { (result) in
            switch result {
            case .success(let schedule):
                print("MCD LOADED")
                self.mcdSchedule = schedule
            case .failure(_):
                break
            }
        }
    }
    
    @objc
    private func loadTrains() {
        guard let service = self.metroService else { return }
        self.service.trainsWorkload(by: model!, all: Array(service.stationsDTO.values), callback: { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.handleWorkload(data)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.hideWorkload()
                }
            }
        })
    }
    
    override func loadView() {
        super.loadView()
        view = stationView
    }
}

extension StationController {
    
    private func colorForEmergency(status: Station.Emergency.Status) -> UIColor {
        switch status {
        case .closed:
            return .mm_Red
        case .emergency:
            return .mm_Warning
        case .info:
            return .mm_Information
        }
    }
    
    private func textColorForEmergency(status: Station.Emergency.Status) -> UIColor {
        switch status {
        case .closed:
            return .mm_Red
        case .emergency:
            return .mm_Warning
        case .info:
            return .mm_Information
        }
    }
    
    private func imageForEmergency(status: Station.Emergency.Status) -> UIImage {
        switch status {
        case .closed:
            return UIImage(named: "closinggg", in: .mm_Map, compatibleWith: nil)!
        case .emergency:
            return UIImage(named: "emergency_circle", in: .mm_Map, compatibleWith: nil)!
        case .info:
            return UIImage(named: "information_circle", in: .mm_Map, compatibleWith: nil)!
        }
    }
    
    private func hideWorkload() {
        if let index = trainsWorkloadSectionIndex, stationView.viewState.sections[safe: index] != nil {
            let newSection = Section(
                title          : nil,
                isNeedToExpand : false,
                isExpanded     : true,
                rows           : [],
                onExpandTap    : nil)
            self.stationView.viewState.sections[index] = newSection
            self.stationView.tableView.reloadSections([index], with: .none)
        }
    }
    
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
    
    private func makeMCDrows(_ stationID: Int, threads: [MCDThread]) -> MCDArrivalTableViewCell.ViewState? {
        guard let station = metroService?.stationsDTO.values.filter({ $0.id == stationID }).first, let three = MCDThread.getNearestThree(threads: threads) else { return nil }
            let items: [MCDArrivaleCollectionViewCell.ViewState] = three.map { item in
                let onSelect = { [weak self] in
                    guard let self = self else { return }
                    self.handleMCDRouteTap(thread: item, isFromSchedule: false)
                }
                
                return MCDArrivaleCollectionViewCell.ViewState(arrivalTime: item.getArrivalString(), onSelect: onSelect, status: self.mcdStatus(status: item.status), platform: item.platform, routeNumb: item.trainNum)
            }
            
            return MCDArrivalTableViewCell.ViewState(towards: String.localizedStringWithFormat(NSLocalizedString("Towards %@", tableName: nil, bundle: .mm_Map, value: "", comment: ""), station.name), items: items)
    }

    private func handleMCDSchedule(_ schedule: MCDSchedule) {
        if let index = trainsWorkloadSectionIndex, stationView.viewState.sections[safe: index] != nil  {
            var rows = [MCDArrivalTableViewCell.ViewState]()
            if let towardsStartRow = self.makeMCDrows(model.line.firstStationID, threads: schedule.start) {
                rows.append(towardsStartRow)
            }
            if let towardsEndRow = self.makeMCDrows(model.line.lastStationID, threads: schedule.end) {
                rows.append(towardsEndRow)
            }
            let lastUpdateRow = StationView.ViewState.TrainsLastUpdate(title: "\(NSLocalizedString("Last update – ", tableName: nil, bundle: .mm_Map, value: "", comment: ""))\(Date().dateByAdding(3, .hour).toFormat("HH:mm:ss"))")
                
            if let first = rows.first, let last = rows.last {
                if first.items.isEmpty && last.items.isEmpty {
                    DispatchQueue.main.async { [weak self] in
                        self?.stationView.viewState.sections[index] = Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [], onExpandTap: nil)
                        self?.stationView.tableView.reloadSections([index], with: .none)
                    }
                } else {
                    let cellStates = rows.map {  StationView.ViewState.MCDArriving.loaded($0) }
                    var finalRows = [Any]()
                    finalRows.append(contentsOf: cellStates)
                    finalRows.append(lastUpdateRow)
                    finalRows.append(StationView.ViewState.Divider())
                    let newSection = Section(title: NSLocalizedString("Train's arriving", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
                                             isNeedToExpand: false,
                                             isExpanded: true,
                                             rows: finalRows,
                                             onExpandTap: nil)
                    DispatchQueue.main.async { [weak self] in
                        self?.stationView.viewState.sections[index] = newSection
                        self?.stationView.tableView.reloadSections([index], with: .none)
                    }
                }
            }
        }
    }

    private func handleWorkload(_ workload: TrainWorkload) {
        if let index = trainsWorkloadSectionIndex, var _ = stationView.viewState.sections[safe: index] {
            var rows = [WagonsLoadTableViewCell.ViewState]()
            for wayData in workload.wayData {
                let trains = wayData.data.map {
                    return WagonLoadCollectionViewCell.ViewState(arrivalTime: $0.arrivalTime, onSelect: {}, wagons: $0.wagonsWorkload.map { WagonLoadCollectionViewCell.ViewState.Load(rawValue: $0.rawValue)! }, isStanding: $0.status == .standing ? true : false)
                }
                rows.append(WagonsLoadTableViewCell.ViewState(towards: wayData.towardsStationName, items: trains))
            }

            let cellStates = rows.map {  StationView.ViewState.TrainsWorkloadData.loaded($0) }
            let lastUpdateRow = StationView.ViewState.TrainsLastUpdate(title: "\(NSLocalizedString("Last update – ", tableName: nil, bundle: .mm_Map, value: "", comment: ""))\(Date().dateByAdding(3, .hour).toFormat("HH:mm:ss"))")
            var finalRows = [Any]()
            finalRows.append(contentsOf: cellStates)
            finalRows.append(lastUpdateRow)
            finalRows.append(StationView.ViewState.Divider())
            let newSection = Section(
                title          : NSLocalizedString("Trains load", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
                isNeedToExpand : false,
                isExpanded     : true,
                rows           : finalRows,
                onExpandTap    : nil)
            self.stationView.viewState.sections[index] = newSection
            self.stationView.tableView.reloadSections([index], with: .none)
        }
    }
    
    private func makeInitialState(from station: Station) -> StationView.ViewState{
        var sections = [Section]()
        var linesAndWorktimeRows = [Any]()
        let mainLineRow = StationView.ViewState.LineData(lineIcon: station.line.originalIcon, lineName: station.line.name)
        var secondaryLinesRows = station.line.neigbourLines.map {
            return StationView.ViewState.LineData(lineIcon: $0.originalIcon, lineName: $0.name)
        }
        secondaryLinesRows.insert(mainLineRow, at: 0)
        linesAndWorktimeRows.append(contentsOf: secondaryLinesRows)
        let worktime = StationView.ViewState.WorktimeData(font: .mm_Body_15_Regular, title: "\(NSLocalizedString("Opened from", tableName: nil, bundle: .mm_Map, value: "", comment: "")) \(station.worktime.open) \(NSLocalizedString("till", tableName: nil, bundle: .mm_Map, value: "", comment: "")) \(station.worktime.close)", color: .mm_TextSecondary)
        linesAndWorktimeRows.append(worktime)
        linesAndWorktimeRows.append(StationView.ViewState.Divider())
        sections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: linesAndWorktimeRows, onExpandTap: nil))
        
        for em in station.emergency {
            let textColor = textColorForEmergency(status: em.status)
            let emergencyRow = StationView.ViewState.EmergencyData(
                leftIcon        : imageForEmergency(status: em.status),
                title           : em.title,
                description     : em.subtitle,
                backgroundColor : colorForEmergency(status: em.status),
                textColor       : textColor,
                onSelect        : { [weak self] in
                    guard let self = self else { return }
                    self.onEmergencyTap?(em)
                })
            sections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [emergencyRow], onExpandTap: nil))
        }
        if !station.emergency.isEmpty {
            sections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [StationView.ViewState.Divider()], onExpandTap: nil))
        }
        var onTransport: (()->())? = nil
        let addToFavoritesTitle = NSLocalizedString("Bookmark", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        let favoritesImage = UIImage(named: "like", in: .mm_Map, compatibleWith: nil)!
        let onBookmark : (()->())? = nil
        let onTrains: ()->() = { [weak self] in
            guard let self = self else { return }
            self.presentTrainsTimeController()
        }
        
        let actionsRow = StationView.ViewState.ActionsRow(
            isMCD: station.isMCD,
            onTransport:  nil,
            onBookmark: onBookmark,
            bookmarkImage: favoritesImage,
            bookmarkTitle: addToFavoritesTitle,
            onTrains: model.schedule.isEmpty ? nil : onTrains,
            onMCD: { [weak self] in
                if let schedule = self?.mcdSchedule {
                    guard let self = self else { return }
//                    self.handleScheduleTap(schedule: schedule)
                }
            })
        sections.append(Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [actionsRow], onExpandTap: nil))
        actionsRowSectionIndex = sections.endIndex - 1
        
        // Пересадки
        if let transitions = station.transitions {
            let transfers = transitions.enumerated().map { (index,transitionStation) in
                return StationView.ViewState.SubtitleData(
                    image: transitionStation.line.originalIcon,
                    imageUrl: nil,
                    title: transitionStation.name,
                    descr: transitionStation.line.name,
                    onSelect: { [weak self] in
                        guard let self = self else { return }
                        self.onTransferStationSelect?(index,transitionStation)
                    })
            }
            var finalRows = [Any]()
            finalRows.append(contentsOf: transfers)
            finalRows.append(StationView.ViewState.Divider())
            sections.append(Section(title: NSLocalizedString("Transfers", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
                                    isNeedToExpand: false,
                                    isExpanded: true,
                                    rows: finalRows,
                                    onExpandTap: nil))
        }
        sections.append(Section(title: nil,
                                isNeedToExpand: false,
                                isExpanded: true,
                                rows: [],
                                onExpandTap: nil))
        self.trainsWorkloadSectionIndex = sections.endIndex - 1
        
        if !model!.features.isEmpty {
            var boolRows = [FeatureTableViewCell.ViewState]()
            for index in stride(from: 0, to: model!.features.endIndex - 1, by: 2) {
                var firstValue: FeatureTableViewCell.ViewState.Feature? = nil
                var secondValue: FeatureTableViewCell.ViewState.Feature? = nil
                if let first = model!.features[safe: index] {
                    firstValue = FeatureTableViewCell.ViewState.Feature(image: first.image, title: first.stationDesc)
                }
                if let second = model!.features[safe: index + 1]{
                    secondValue = FeatureTableViewCell.ViewState.Feature(image: second.image, title: second.stationDesc)
                }
                boolRows.append(FeatureTableViewCell.ViewState(first: firstValue, second: secondValue))
            }
            
            if !(model!.features.count % 2 == 0) {
                if let last = model!.features.last {
                    boolRows.append(FeatureTableViewCell.ViewState(first: FeatureTableViewCell.ViewState.Feature(image: last.image, title: last.stationDesc), second: nil))
                }
            }
            var finalRows = [Any]()
            finalRows.append(contentsOf: boolRows)
            finalRows.append(StationView.ViewState.Divider())
            sections.append(Section(title: NSLocalizedString("Services", tableName: nil, bundle: .mm_Map, value: "", comment: ""), isNeedToExpand: false, isExpanded: true, rows: finalRows, onExpandTap: nil))
        }
        
        return StationView.ViewState(stationTitle: station.name,
                                     sections: sections,
                                     onClose: { [weak self] in self?.onClose?() })
    }
    
    private func handleScheduleTap(schedule: MCDSchedule) {
        guard let service = self.metroService else { return }
        let scheduleVC = MCDScheduleViewController()
        let nav = BaseNavigationController(rootViewController: scheduleVC)

        self.present(nav, animated: true, completion: nil)
        

        if let startStation = service.stationsDTO.values.filter({ $0.id == model.line.firstStationID }).first,
           let endStation = service.stationsDTO.values.filter({ $0.id == model.line.lastStationID }).first {
            scheduleVC.towardsStartName = String.localizedStringWithFormat(NSLocalizedString("To %@", tableName: nil, bundle: .mm_Map, value: "", comment: ""), startStation.name)
            scheduleVC.towardsEndName = String.localizedStringWithFormat(NSLocalizedString("To %@", tableName: nil, bundle: .mm_Map, value: "", comment: ""), endStation.name)
        }
     
        scheduleVC.towardsStart = schedule.start
        scheduleVC.towardsEnd = schedule.end
        scheduleVC.setTitle("\(model.name)")
    }

    private func handleMCDRouteTap(thread: MCDThread, isFromSchedule: Bool) {
        let routeVC = MCDRouteScreen()
        let nav = BaseNavigationController(rootViewController: routeVC)
        self.present(nav, animated: true, completion: nil)
        routeVC.title = NSLocalizedString("Route", tableName: nil, bundle: .mm_Map, value: "", comment: "") + " \("№\(thread.trainNum)")"
        routeVC.addCloseButton()
        routeVC.idtr = thread.idtr
    }
    
    private func presentTrainsTimeController() {
        let destination = StationTrainsScheduleController()
        let floatingPanel = BasePanelController(contentVC: destination, positions: .modal, state: .full)
        self.present(floatingPanel, animated: true, completion: nil)
        destination.model = model
        floatingPanel.track(scrollView: destination.tableView)
    }
}
