//
//  StationTrainsScheduleController.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 07.11.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class StationTrainsScheduleController: BasePanFullScreenController  {
    
    convenience init() {
        self.init(nibName: "BasePanFullScreenController", bundle: .mm_Map)
    }
    
    var model: Station! {
        didSet {
           makeState()
        }
    }
    
    var viewState: ViewState = ViewState(sections: []) {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    struct ViewState {
        let sections: [Section]
        
        struct ScheduleData {
            let title: String
            let oddTimes: [String]
            let evenTimes: [String]
        }
        
        struct Divider { }
    }
}

extension StationTrainsScheduleController {
    
    private func makeState() {
        var sections = [Section]()
        for schedule in model.schedule {
            let groupedWeekDays = Dictionary(grouping: schedule.items, by: { $0.isWeekend })
            var rows = [Any]()
            for item in groupedWeekDays {
                let oddTimes: [[String]] = item.value.compactMap {
                    if $0.dayType == .odd {
                        let res = [$0.firstTrain,$0.lastTrain]
                        return res
                    }
                    return nil
                }
                
                let evenTimes: [[String]] = item.value.compactMap {
                    if $0.dayType == .even {
                        let res = [$0.firstTrain,$0.lastTrain]
                        return res
                    }
                    return nil
                }
                
                let state = ViewState.ScheduleData(title: item.key ? NSLocalizedString("On weekend", tableName: nil, bundle: .mm_Map, value: "", comment: "") : NSLocalizedString("On weekdays", tableName: nil, bundle: .mm_Map, value: "", comment: ""), oddTimes: oddTimes.first ?? [], evenTimes: evenTimes.first ?? [])
                rows.append(state)
                rows.append(ViewState.Divider())
            }
            sections.append(Section(title: String.localizedStringWithFormat(NSLocalizedString("Towards %@", tableName: nil, bundle: .mm_Map, value: "", comment: ""), schedule.towardsName), isNeedToExpand: false, isExpanded: true, rows: rows, onExpandTap: nil))
            
        }
        self.viewState = ViewState(sections: sections)
    }
    
    private func setup() {
        self.titleLabel.text = NSLocalizedString("Trains schedule", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(TrainScheduleTableViewCell.nib, forCellReuseIdentifier: TrainScheduleTableViewCell.identifire)
        self.tableView.register(DividerTableViewCell.nib, forCellReuseIdentifier: DividerTableViewCell.identifire)
        self.tableView.estimatedSectionHeaderHeight = 25
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.onClose = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension StationTrainsScheduleController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewState.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewState.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewState.sections[indexPath.section].rows[indexPath.row]
        switch item {
        case is ViewState.ScheduleData:
            guard
                let data = item as? ViewState.ScheduleData,
                let cell = tableView.dequeueReusableCell(withIdentifier: TrainScheduleTableViewCell.identifire, for: indexPath) as? TrainScheduleTableViewCell
            else { return UITableViewCell() }
            cell.viewState = data
            return cell
        case is ViewState.Divider:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: DividerTableViewCell.identifire, for: indexPath) as? DividerTableViewCell
            else { return UITableViewCell() }
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension StationTrainsScheduleController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.isHidden    = false
        cell.alpha = 0
        UIView.animate( withDuration: animationDuration, delay: delay * Double(indexPath.row), animations: {
            cell.alpha = 1
        })
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableView.isHidden    = false
        view.alpha = 0
        UIView.animate(withDuration: animationDuration, delay: delay * Double(section), animations: {
                view.alpha = 1
        })
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let title = viewState.sections[section].title {
            let headerView = LargeSectionHeader.loadFromNib()
            headerView.titleLabel.text = title
            return headerView
        }
        return nil
    }
}
