//
//  MCDRouteScreen.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 16.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class MCDRouteScreen : BaseController {
    
    public var onClose : (()->())?
    public var allStations : [StationDTO] = []

    @IBOutlet weak var tableView   : UITableView!
    
    @objc
    private func handleClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    var idtr: Int? {
        didSet {
            if let idtr = idtr {
                self.loadData(for: idtr)
            } else {
                self.makeErrorState()
            }
        }
    }
    
    private func loadData(for id: Int?) {
        guard let id = id else {
            makeErrorState()
            return
        }
        MCDStop.getStops(by: id, for: allStations, callback: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.makeState(stops: data)
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    print(err)
                    self.makeErrorState()
                }
            }
        })
    }

    public func addCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close_pan"), style: .plain, target: self, action: #selector(self.handleClose))
    }

    private func statusHelper(for stop: MCDStop) -> String {
        if stop.arrival < Date().addingTimeInterval(3600*3) {
            switch stop.status {
            case .late(let mins):
                return String.localizedStringWithFormat(NSLocalizedString("Arrived %d min late", tableName: nil, bundle: .mm_Map, value: "", comment: ""), mins)
            case .early(let mins):
                return String.localizedStringWithFormat(NSLocalizedString("Arrived %d min earlier", tableName: nil, bundle: .mm_Map, value: "", comment: ""), mins)
            case .standart:
                return NSLocalizedString("Arrived on schedule", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            }
        } else {
            switch stop.status {
            case .late(let mins):
                return String.localizedStringWithFormat(NSLocalizedString("Possible delay %d min", tableName: nil, bundle: .mm_Map, value: "", comment: ""), mins)
            case .early(let mins):
                return String.localizedStringWithFormat(NSLocalizedString("Arriving %d min earlier", tableName: nil, bundle: .mm_Map, value: "", comment: ""), mins)
            case .standart:
                return NSLocalizedString("On schedule", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            }
        }
    }
    
    private func platformHelper(for stop: MCDStop) -> String? {
//        if let platform = stop.platform {
//            return String.localizedStringWithFormat("Platform %d".localized(), platform)
//        }
        return nil
    }
    
    private func isPassed(stop: MCDStop) -> Bool {
        return stop.arrival < Date().addingTimeInterval(3600*3)
    }
    
    private func makeErrorState() {
        
        let errRow = ViewState.ErrorData(title: NSLocalizedString("Error", tableName: nil, bundle: .mm_Map, value: "", comment: ""), descr: NSLocalizedString("Oops! Something went wrong", tableName: nil, bundle: .mm_Map, value: "", comment: ""), onRetry: { [weak self] in
            guard let self = self else { return }
            self.loadData(for: self.idtr)
        })
        let section = Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [errRow], onExpandTap: nil)
        self.viewState = ViewState(state: .error(errRow), sections: [section])
    }
    
    private func makeState(stops: [MCDStop]) {
        var mutable = stops
        var sections = [Section]()
        if mutable.isEmpty {
            self.makeErrorState()
            return
        }
        let first = mutable.removeFirst()

        let firstRow = ViewState.FirstStopData(name: first.stationName,
                                               platform: platformHelper(for: first),
                                               status: statusHelper(for: first),
                                               statusColor: first.status.color(),
                                               color: first.color,
                                               timeToStop: first.arrival.toFormat("HH:mm"),
                                               isPassed: isPassed(stop: first))
        
        
        let firstSection = Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [firstRow], onExpandTap: nil)
        sections.append(firstSection)
        let last = mutable.removeLast()
        let lastRow = ViewState.LastStopData(name: last.stationName,
                                               platform: platformHelper(for: last),
                                               status: statusHelper(for: last),
                                               statusColor: last.status.color(),
                                               color: last.color,
                                               timeToStop: last.arrival.toFormat("HH:mm"),
                                               isPassed: isPassed(stop: last))
        
//        let middleStops: [ViewState.StopData] = mutable.map { stop in
//            return ViewState.StopData(name: stop.stationName,
//                                      platform: platformHelper(for: stop),
//                                      status: statusHelper(for: stop),
//                                      statusColor: stop.status.color(),
//                                      color: stop.color,
//                                      timeToStop: stop.arrival.toFormat("HH:mm"),
//                                      isPassed: isPassed(stop: stop),
//                                      isShown: true)
//
//        }
        let passedStops = mutable.filter { isPassed(stop: $0) }.map { stop in
            return ViewState.StopData(name: stop.stationName,
                                      platform: platformHelper(for: stop),
                                      status: statusHelper(for: stop),
                                      statusColor: stop.status.color(),
                                      color: stop.color,
                                      timeToStop: stop.arrival.toFormat("HH:mm"),
                                      isPassed: true)
            
        }

        let passedSection = Section(title: nil, isNeedToExpand: passedStops.count > 3 ? true : false, isExpanded: passedStops.count > 3 ? false : true, rows: passedStops, onExpandTap: nil)
        sections.append(passedSection)





        let futureStops = mutable.filter { !isPassed(stop: $0) }.map { stop in
            return ViewState.StopData(name: stop.stationName,
                                      platform: platformHelper(for: stop),
                                      status: statusHelper(for: stop),
                                      statusColor: stop.status.color(),
                                      color: stop.color,
                                      timeToStop: stop.arrival.toFormat("HH:mm"),
                                      isPassed: false)

        }


        let futureSection = Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: futureStops, onExpandTap: nil)
        let lastSection = Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: [lastRow], onExpandTap: nil)
        sections.append(contentsOf: [futureSection,lastSection])



        DispatchQueue.main.async {
            self.viewState = ViewState(state: .loaded, sections: sections)
        }
    }


    @objc private func handleExpand(section: Int) {
        if let _ = self.viewState.sections[safe: section] {
            let indexPaths = viewState.sections[section].rows.indices.map { IndexPath(row: $0, section: section) }
            self.isExpanding = true
            viewState.sections[section].isExpanded.toggle()
            viewState.sections[section].isExpanded ? tableView.insertRows(at: indexPaths, with: .fade) : tableView.deleteRows(at: indexPaths, with: .fade)
            self.isExpanding = false
        }
    }
    
    struct ViewState {
        
        enum State {
            case loading
            case error(ErrorData)
            case loaded
        }
        var state: State
        var sections: [Section]



        struct ErrorData : _ErrorData {
            let title           : String
            let descr            : String
            let onRetry         : () -> ()
        }
            
        struct  FirstStopData {
            let name: String
            let platform: String?
            let status: String
            let statusColor: UIColor
            let color: UIColor
            var timeToStop: String?
            var isPassed: Bool
        }
        
        struct  StopData {
            let name: String
            let platform: String?
            let status: String
            let statusColor: UIColor
            let color: UIColor
            var timeToStop: String?
            var isPassed: Bool
        }
        
        struct  LastStopData {
            let name: String
            let platform: String?
            let status: String
            let statusColor: UIColor
            let color: UIColor
            var timeToStop: String?
            var isPassed: Bool
        }
    }
    
    private var isExpanding = false

    public var viewState : ViewState = ViewState(state: .loading, sections: []){
        didSet {
            if let tableView = tableView {
                if !isExpanding {
                    tableView.reloadData()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        if #available(iOS 13.0, *) {
//            let effect = UIBlurEffect(style: .systemMaterial)
//            self.bgBlurView.effect = effect
//            self.view = bgBlurView
//        }
        tableView.register(UINib(nibName: MCDFirstStopTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: MCDFirstStopTableViewCell.reuseID)
        tableView.register(UINib(nibName: MCDStopTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: MCDStopTableViewCell.reuseID)
        tableView.register(UINib(nibName: MCDLastStopTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: MCDLastStopTableViewCell.reuseID)

        tableView.register(LoadingTableViewCell.nib, forCellReuseIdentifier: LoadingTableViewCell.identifire)
        tableView.register(UINib(nibName: ErrorTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: ErrorTableViewCell.reuseID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50.0
        tableView.estimatedSectionHeaderHeight = 1
        tableView.estimatedSectionFooterHeight = 1
        tableView.sectionFooterHeight = 1
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.onClose?()
    }
}

extension MCDRouteScreen : UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        tableView.isHidden    = false
//        cell.alpha = 0
//        UIView.animate( withDuration: animationDuration, delay: delay * Double(indexPath.row), animations: {
//            cell.alpha = 1
//        })
//    }
//    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        tableView.isHidden    = false
//        view.alpha = 0
//        UIView.animate(withDuration: animationDuration, delay: delay * Double(section), animations: {
//                view.alpha = 1
//        })
//    }
}

extension MCDRouteScreen : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if case .loaded = viewState.state {
            if let sectionData = viewState.sections[safe: section] {
                if sectionData.isNeedToExpand {
                    let expandView = Bundle.main.loadNibNamed("MCDExpandView", owner: nil, options: nil)?.first as! MCDExpandView
                    expandView.isExpanded = viewState.sections[section].isExpanded
                    expandView.onTap = { [weak self] in
                        guard let self = self else { return }
                        expandView.isExpanded.toggle()
                        self.handleExpand(section: section)
                    }
                    expandView.stationsCountLabel.text =  String.localizedStringWithFormat(NSLocalizedString("stations count", tableName: nil, bundle: .mm_Map, value: "", comment: ""), viewState.sections[section].rows.count)
                    return expandView
                }
            }
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if case .loaded = viewState.state {
            if viewState.sections[section].isNeedToExpand {
                return 65
            }
        }
        return CGFloat.leastNormalMagnitude



    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if case .loaded = viewState.state {
            if viewState.sections[section].isNeedToExpand {
                return 65
            }
        }
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewState.state {
        case .error            :
            return 1
        case .loading          :
            return 1
        case .loaded :
            return viewState.sections[section].isExpanded ? viewState.sections[section].rows.count : 0
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        switch viewState.state {
        case .error            :
            return 1
        case .loading          :
            return 1
        case .loaded :
            return viewState.sections.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewState.state {
        case .loading           :
            let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.identifire, for: indexPath) as! LoadingTableViewCell
            cell.separatorInset         = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            tableView.separatorStyle    = .none
            return cell
        case .error(let errData):
            let cell = tableView.dequeueReusableCell(withIdentifier: ErrorTableViewCell.identifire, for: indexPath) as! ErrorTableViewCell
            cell.configure(errData)
            tableView.separatorStyle    = .none
            return cell
        case .loaded :
            let row = viewState.sections[indexPath.section].rows[indexPath.row]
            switch row {
            case is ViewState.FirstStopData :
                let d = row as! ViewState.FirstStopData
                let cell = tableView.dequeueReusableCell(withIdentifier: MCDFirstStopTableViewCell.reuseID, for: indexPath) as! MCDFirstStopTableViewCell
                cell.selectionStyle = .none
                cell.circleView.backgroundColor = d.isPassed ? .grey : d.color
                cell.outsideLineView.backgroundColor = d.isPassed ? .grey : d.color
                cell.stationNameLabel.text = d.name
                cell.platformNameLabel.text = d.platform
                cell.statusLabel.text = d.status
                cell.statusLabel.textColor = d.isPassed ? d.statusColor.withAlphaComponent(0.6) : d.statusColor
                if let _ = d.platform {
                    cell.statusLabelToStation.priority = UILayoutPriority(997)
                    cell.statusLabelToPlatform.priority = UILayoutPriority(1000)
                    cell.platformNameLabel.isHidden = false
                } else {
                    cell.statusLabelToStation.priority = UILayoutPriority(1000)
                    cell.statusLabelToPlatform.priority = UILayoutPriority(997)
                    cell.platformNameLabel.isHidden = true
                }
                cell.timeToStopLabel.text = d.timeToStop
                
                return cell
            case is ViewState.StopData     :
                let d = row as! ViewState.StopData
                let cell = tableView.dequeueReusableCell(withIdentifier: MCDStopTableViewCell.reuseID, for: indexPath) as! MCDStopTableViewCell
                cell.selectionStyle = .none
                cell.outsideCircleView.backgroundColor = d.isPassed ? .grey : d.color
                cell.insideCircleView.backgroundColor = .MKBase
                cell.outsideLineView.backgroundColor = d.isPassed ? .grey : d.color
                cell.stationNameLabel.text = d.name
                cell.platformNameLabel.text = d.platform
                cell.statusLabel.text = d.status
                cell.statusLabel.textColor = d.isPassed ? d.statusColor.withAlphaComponent(0.6) : d.statusColor
                cell.timeToStopLabel.text = d.timeToStop
                if let _ = d.platform {
                    cell.statusLabelToStation.priority = UILayoutPriority(997)
                    cell.statusLabelToPlatform.priority = UILayoutPriority(1000)
                    cell.platformNameLabel.isHidden = false
                } else {
                    cell.statusLabelToStation.priority = UILayoutPriority(1000)
                    cell.statusLabelToPlatform.priority = UILayoutPriority(997)
                    cell.platformNameLabel.isHidden = true
                }
           
                return cell
            case is ViewState.LastStopData :
                let d = row as! ViewState.LastStopData
                let cell = tableView.dequeueReusableCell(withIdentifier: MCDLastStopTableViewCell.reuseID, for: indexPath) as! MCDLastStopTableViewCell
                cell.selectionStyle = .none
                cell.circleView.backgroundColor = d.isPassed ? .grey : d.color
                cell.outsideLineView.backgroundColor = d.color
                cell.stationNameLabel.text = d.name
                cell.platformNameLabel.text = d.platform
                cell.statusLabel.text = d.status
                cell.statusLabel.textColor = d.isPassed ? d.statusColor.withAlphaComponent(0.6) : d.statusColor
                cell.timeToStopLabel.text = d.timeToStop
                if let _ = d.platform {
                    cell.statusLabelToStation.priority = UILayoutPriority(997)
                    cell.statusLabelToPlatform.priority = UILayoutPriority(1000)
                    cell.platformNameLabel.isHidden = false
                } else {
                    cell.statusLabelToStation.priority = UILayoutPriority(1000)
                    cell.statusLabelToPlatform.priority = UILayoutPriority(997)
                    cell.platformNameLabel.isHidden = true
                }
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
}
