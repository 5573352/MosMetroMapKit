//
//  RouteEmergenciesController.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 26.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit

class RouteEmergenciesController: BasePanFullScreenController {
    
    public var service : MetroService?
    
    convenience init() {
        self.init(nibName: "BasePanFullScreenController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    var model: [Emergency] = [] {
        didSet {
            setState()
        }
    }
    
    var viewState: ViewState = .loading {
        didSet {
            tableView.reloadData()
        }
    }
}

// MARK: - View State
extension RouteEmergenciesController {
    
    enum ViewState {
        case loading
        case loaded([StationEmergencyData])
        
        struct StationEmergencyData : _RouteStationEmergencyTableViewCell {
            var hideDevider    : Bool
            var stationName    : String
            var line           : String
            var lineIcon       : UIImage
            var emergencyTitle : String
            var emergencyIcon  : UIImage
            var color          : UIColor
            var desc           : String
        }
    }
}

extension RouteEmergenciesController {
    
    private func iconFor(emergency: Emergency.StationEmergency) -> UIImage {
        let image = #imageLiteral(resourceName: "information_circle")
        switch emergency.status {
        case .closed:
            return #imageLiteral(resourceName: "closinggg")
        case .emergency:
            return #imageLiteral(resourceName: "alert")
        case .info:
            return image
        }
    }
    
    private func colorFor(emergency: Emergency.StationEmergency) -> UIColor {
        switch emergency.status {
        case .closed:
            return UIColor.metroClosing
        case .emergency:
            return UIColor.metroOrange
        case .info:
            return UIColor.metroLink
        }
    }
    
    private func setState() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var items = [ViewState.StationEmergencyData]()
            for emergency in self.model {
                for station in emergency.stations {
                    guard let service = self.service else { continue }
                    if let stationObj = service.stations.filter({ $0.id == station.id }).first {
                        let item = ViewState.StationEmergencyData(hideDevider    : items.count == 0 ? true : false,
                                                                  stationName    : stationObj.name,
                                                                  line           : stationObj.line.name,
                                                                  lineIcon       : stationObj.line.originalIcon,
                                                                  emergencyTitle : station.title,
                                                                  emergencyIcon  : self.iconFor(emergency: station),
                                                                  color          : self.colorFor(emergency: station),
                                                                  desc           : station.description)
                        items.append(item)
                    }
                }
            }
            DispatchQueue.main.async {
                self.viewState = .loaded(items)
            }
        }
    }
    
    private func setup() {
        self.titleLabel.text = "Emergencies".localized()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LoadingTableViewCell.nib, forCellReuseIdentifier: LoadingTableViewCell.identifire)
        tableView.register(RouteStationEmergencyTableViewCell.nib, forCellReuseIdentifier: RouteStationEmergencyTableViewCell.identifire)
        onClose = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
}

extension RouteEmergenciesController: UITableViewDelegate {
    
}

extension RouteEmergenciesController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewState {
        case .loading:
            return 1
        case .loaded(let items):
            return items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewState {
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.identifire, for: indexPath) as! LoadingTableViewCell
            return cell
        case .loaded(let items):
            let item = items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: RouteStationEmergencyTableViewCell.identifire, for: indexPath) as! RouteStationEmergencyTableViewCell
            cell.configure(with: item)
            return cell
        }
    }
}
