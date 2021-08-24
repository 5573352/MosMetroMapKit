//
//  RouteDetailsView.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 28.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit


func typeOut(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    items.forEach {
        Swift.print($0, separator: separator, terminator: terminator)
    }
    #endif
}

struct SectionSeparator { }

let animationDuration = 0.3
let delay = 0.01

struct Section {
    let title          : String?
    let isNeedToExpand : Bool
    var isExpanded     : Bool
    var rows           : [Any]
    let onExpandTap    : ((Int) -> ())?
}

class RouteDetailsView: UIView {
    
    var firstAppearence = true

    struct ViewState {

        var isExpanding      = false
        var sections         : [Section]
        let totalTime        : String
        let transfersAndCost : String
            
        enum State {
            case loading
            case loaded
        }
                
        struct ActionWithImageData : _ActionSubtitleCell {
            var color        : UIColor
            var title        : String
            var subtitle     : String
            var rightImage   : UIImage
            var onSelect     : (()->())
        }
            
        struct EntryData      : _EntryTableViewCell {
            var image        : UIImage
            var text         : String
            var time         : String
        }
            
        struct InfoWagonLoad  : _LastUpdateWithLineTableViewCell {
            var color        : UIColor
            var info         : String
        }
            
        struct LastUpdateWagonLoad : _LastUpdTableViewCell {
            var color        : UIColor
            var lastUpdate   : String
        }
            
        struct MCDInfoWagonLoad : _InfoForSheduleTableViewCell {
            var color        : UIColor
            var info         : String
        }
            
        struct MCDLastUpdateWagonLoad : _MCDLastUpdateTableViewCell {
            var color        : UIColor
            var lastUpdate   : String
        }
            
        enum MCDArriving {
            case error(ErrorData)
            case loading
            case loaded(MCDNearestTrainCell.ViewState)

            struct ErrorData {
                let title    : String
                let subtitle : String
                let image    : UIImage
            }
        }
            
        struct TransferData   : _TransferTableViewCell    {
            var image        : UIImage
            var text         : String
            var time         : String
        }
            
        struct LineSectionData : _LineTableViewCell       {
            var name         : String
            var lineIcon     : UIImage
            var time         : String
            var direction    : String
            var wagon        : [Wagons]
            var advice       : String
            var firstStation : Stop
            var isOutlined   : Bool
            var timeToStop   : String?
        }
            
        struct SingleStopCell : _SingleStopCell           {
            var name         : String
            var lineIcon     : UIImage
            var firstStation : Stop
            var isOutlined   : Bool
            var timeToStop   : String
        }
            
        struct StopData       : _StopTableViewCell        {
            var stop         : Stop
            var isOutlined   : Bool
            var timeToStop   : String?
        }
            
        struct LastStopData   : _LastSectionTableViewCell {
            var stop         : Stop
            var isOutlined   : Bool
            var timeToStop   : String?
        }
            
        struct ValidationData : _ValidationCell           {
            var image        : UIImage
            var price        : String
            var title        : String
        }
            
        struct Rate           : _RouteRateTableViewCell   {
            var onLike       : (()->())
            var onDislike    : (()->())
        }
            
        struct EmergencyData {
            let onSelect     : (()->())
        }
            
        static let initial = ViewState(sections: [], totalTime: "55 min", transfersAndCost: "COST AND TRANSFER")
    }
    
    public var viewState: ViewState = .initial {
        didSet {
            if case .loaded = state {
                render(isExpanding: viewState.isExpanding)
            }
        }
    }
    
    public var state: ViewState.State = .loading {
        didSet {
            if case .loaded = state {
                render(isExpanding: viewState.isExpanding)
            }
        }
    }
    
    var cellHeights = [IndexPath: CGFloat]()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .mm_Base
        view.isOpaque = true
        view.roundCorners(.top, radius: 16)
        return view
    }()
    
    public let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.register(ValidationCell.nib,                  forCellReuseIdentifier: ValidationCell.identifire)
        tableView.register(StopTableViewCell.nib,               forCellReuseIdentifier: StopTableViewCell.identifire)
        tableView.register(LineTableViewCell.nib,               forCellReuseIdentifier: LineTableViewCell.identifire)
        tableView.register(EntryTableViewCell.nib,              forCellReuseIdentifier: EntryTableViewCell.identifire)
        tableView.register(SingleLineStopCell.nib,              forCellReuseIdentifier: SingleLineStopCell.identifire)
        tableView.register(ActionSubtitleCell.nib,              forCellReuseIdentifier: ActionSubtitleCell.identifire)
        tableView.register(LastUpdTableViewCell.nib,            forCellReuseIdentifier: LastUpdTableViewCell.identifire)
        tableView.register(LoadingTableViewCell.nib,            forCellReuseIdentifier: LoadingTableViewCell.identifire)
        tableView.register(TransferTableViewCell.nib,           forCellReuseIdentifier: TransferTableViewCell.identifire)
        tableView.register(RouteRateTableViewCell.nib,          forCellReuseIdentifier: RouteRateTableViewCell.identifire)
        tableView.register(LastSectionTableViewCell.nib,        forCellReuseIdentifier: LastSectionTableViewCell.identifire)
        tableView.register(MCDLastUpdateCell.nib,      forCellReuseIdentifier: MCDLastUpdateCell.identifire)
        tableView.register(InfoForSheduleCell.nib,     forCellReuseIdentifier: InfoForSheduleCell.identifire)
        tableView.register(LineLoadWagonsTableViewCell.nib,     forCellReuseIdentifier: LineLoadWagonsTableViewCell.identifire)
        tableView.register(RouteEmergencyTableViewCell.nib,     forCellReuseIdentifier: RouteEmergencyTableViewCell.identifire)
        tableView.register(MCDNearestTrainCell.nib,    forCellReuseIdentifier: MCDNearestTrainCell.identifire)
        tableView.register(LastUpdateWithLineTableViewCell.nib, forCellReuseIdentifier: LastUpdateWithLineTableViewCell.identifire)
        
        tableView.estimatedRowHeight = 50.0
        tableView.estimatedSectionHeaderHeight = 1
        tableView.estimatedSectionFooterHeight = 1
        tableView.sectionFooterHeight = 1
        return tableView
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .mm_Body_20_Bold
        label.textColor = .mm_TextPrimary
        return label
    }()
    
    private let transitionsAndCostLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mm_TextPrimary
        label.font = .mm_Body_17_Regular
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RouteDetailsView {
    
    private func setup() {
        addSubview(contentView)
        contentView.pin(on: self, {[
            $0.topAnchor    .constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor, constant: 0),
            $0.leftAnchor   .constraint(equalTo: $1.leftAnchor,   constant: 2),
            $0.rightAnchor  .constraint(equalTo: $1.rightAnchor,  constant: -2),
            $0.bottomAnchor .constraint(equalTo: $1.bottomAnchor, constant: 0)
        ]})
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.pin(on: contentView, {[
            $0.leftAnchor   .constraint(equalTo: $1.leftAnchor,   constant: 0),
            $0.topAnchor    .constraint(equalTo: $1.topAnchor,    constant: 12),
            $0.rightAnchor  .constraint(equalTo: $1.rightAnchor,  constant: 0),
            $0.bottomAnchor .constraint(equalTo: $1.bottomAnchor, constant: 0)
        ]})
    }
    
    private func render(isExpanding: Bool) {
        if !isExpanding {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc
    func handleExpandAndClose(section: Int) {
        if case .loaded = state {
            viewState.isExpanding = true
            var indexPaths = [IndexPath]()
            for row in viewState.sections[section].rows.indices {
                let iPath = IndexPath(row: row, section: section)
                typeOut(section,row)
                indexPaths.append(iPath)
            }
            let _isExpanded = viewState.sections[section].isExpanded
            viewState.sections[section].isExpanded = !_isExpanded
            state = .loaded
            if _isExpanded {
                tableView.deleteRows(at: indexPaths, with: .fade)
            } else {
                tableView.insertRows(at: indexPaths, with: .fade)
            }
        }
    }
}

extension RouteDetailsView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch state {
        case .loading:
            return 1
        case .loaded:
            return viewState.sections.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .loading:
            return 1
        case .loaded:
            if viewState.sections[section].isExpanded {
                return viewState.sections[section].rows.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
        if firstAppearence {
            tableView.isHidden    = false
            cell.alpha = 0
            UIView.animate( withDuration: animationDuration, delay: delay * Double(indexPath.row), animations: {
                cell.alpha = 1
            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .loading:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.identifire, for: indexPath) as? LoadingTableViewCell
            else { return UITableViewCell() }
            return cell
            break
        case .loaded:
            switch viewState.sections[indexPath.section].rows[indexPath.row] {
            case is ViewState.SingleStopCell:
                guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.SingleStopCell,
                    let cell = tableView.dequeueReusableCell(withIdentifier: SingleLineStopCell.identifire,              for: indexPath) as? SingleLineStopCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is ViewState.EntryData:
                guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.EntryData,
                    let cell = tableView.dequeueReusableCell(withIdentifier: EntryTableViewCell.identifire,              for: indexPath) as? EntryTableViewCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is ViewState.InfoWagonLoad:
                 guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.InfoWagonLoad,
                    let cell = tableView.dequeueReusableCell(withIdentifier: LastUpdateWithLineTableViewCell.identifire, for: indexPath) as? LastUpdateWithLineTableViewCell
                 else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is ViewState.LastUpdateWagonLoad:
                guard let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.LastUpdateWagonLoad,
                      let cell = tableView.dequeueReusableCell(withIdentifier: LastUpdTableViewCell.identifire,            for: indexPath) as? LastUpdTableViewCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is ViewState.MCDInfoWagonLoad:
                guard let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.MCDInfoWagonLoad,
                      let cell = tableView.dequeueReusableCell(withIdentifier: InfoForSheduleCell.identifire,     for: indexPath) as? InfoForSheduleCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is ViewState.MCDLastUpdateWagonLoad:
                guard let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.MCDLastUpdateWagonLoad,
                      let cell = tableView.dequeueReusableCell(withIdentifier: MCDLastUpdateCell.identifire,      for: indexPath) as? MCDLastUpdateCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is MCDNearestTrainCell.ViewState:
                guard let data = viewState.sections[indexPath.section].rows[indexPath.row] as? MCDNearestTrainCell.ViewState,
                      let cell = tableView.dequeueReusableCell(withIdentifier: MCDNearestTrainCell.identifire,    for: indexPath) as? MCDNearestTrainCell
                else { return UITableViewCell() }
                cell.viewState = data
                return cell
            case is LineLoadWagonsTableViewCell.ViewState:
                guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? LineLoadWagonsTableViewCell.ViewState,
                    let cell = tableView.dequeueReusableCell(withIdentifier: LineLoadWagonsTableViewCell.identifire,     for: indexPath) as? LineLoadWagonsTableViewCell
                else { return UITableViewCell() }
                cell.viewState = data
                return cell
            case is ViewState.TransferData:
                guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.TransferData,
                    let cell = tableView.dequeueReusableCell(withIdentifier: TransferTableViewCell.identifire,           for: indexPath) as? TransferTableViewCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is ViewState.LineSectionData:
                guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.LineSectionData,
                    let cell = tableView.dequeueReusableCell(withIdentifier: LineTableViewCell.identifire,               for: indexPath) as? LineTableViewCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is ViewState.StopData:
                guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.StopData,
                    let cell = tableView.dequeueReusableCell(withIdentifier: StopTableViewCell.identifire,               for: indexPath) as? StopTableViewCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is ViewState.LastStopData:
                guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.LastStopData,
                    let cell = tableView.dequeueReusableCell(withIdentifier: LastSectionTableViewCell.identifire,        for: indexPath) as? LastSectionTableViewCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is ViewState.ValidationData:
                guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.ValidationData,
                    let cell = tableView.dequeueReusableCell(withIdentifier: ValidationCell.identifire,                  for: indexPath) as? ValidationCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is ViewState.ActionWithImageData:
                guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.ActionWithImageData,
                    let cell = tableView.dequeueReusableCell(withIdentifier: ActionSubtitleCell.identifire,           for: indexPath) as? ActionSubtitleCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is ViewState.Rate:
                guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.Rate,
                    let cell = tableView.dequeueReusableCell(withIdentifier: RouteRateTableViewCell.identifire,          for: indexPath) as? RouteRateTableViewCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            case is ViewState.EmergencyData:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: RouteEmergencyTableViewCell.identifire,     for: indexPath) as? RouteEmergencyTableViewCell
                else { return UITableViewCell() }
                return cell
            default:
                break
            }
        }
        return UITableViewCell()
    }
}

extension RouteDetailsView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if case .loaded = state {
            if viewState.sections[section].isNeedToExpand {
                return 40
            }
            else if viewState.sections[section].title != nil {
                return 32
            }
            else {
                return CGFloat.leastNormalMagnitude
            }
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if case .loaded = state {
            if viewState.sections[section].isNeedToExpand {
                return 40
            }
            else if viewState.sections[section].title != nil {
                return 32
            }
            else {
                return CGFloat.leastNormalMagnitude
            }
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if case .loaded = state {
            if viewState.sections[section].isNeedToExpand{
                let expandView = SectionExpander.loadFromNib()
                expandView.isExpanded = viewState.sections[section].isExpanded
                expandView.onTap = { [weak self] in
                    guard let self = self else { return }
                    expandView.isExpanded.toggle()
                    self.handleExpandAndClose(section: section)
                }
                expandView.stationsCountLabel.text =  String.localizedStringWithFormat(NSLocalizedString("stations count", tableName: nil, bundle: .mm_Map, value: "", comment: ""), viewState.sections[section].rows.count)
                guard let firstElement = viewState.sections[section].rows[safe: 0] as? ViewState.StopData else { return nil }
                expandView.linePathView.backgroundColor = firstElement.stop.color
                guard let item = viewState.sections[section].rows.first else { return expandView }
                switch item {
                case is ViewState.SingleStopCell:
                    break
                case is ViewState.LineSectionData:
                    guard
                        let data = item as? ViewState.LineSectionData
                    else { return nil }
                    expandView.linePathMiddleView.isHidden = data.isOutlined ? false : true
                case is ViewState.StopData:
                    guard
                        let data = item as? ViewState.StopData
                    else { return nil }
                    expandView.linePathMiddleView.isHidden = data.isOutlined ? false : true
                case is ViewState.LastStopData:
                    guard
                        let data = item as? ViewState.LastStopData
                    else { return nil }
                    expandView.linePathMiddleView.isHidden = data.isOutlined ? false : true
                default:
                    break
                }
                return expandView
            } else {
                return nil
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .loaded = state {
            switch viewState.sections[indexPath.section].rows[indexPath.row] {
            
            case is ViewState.ActionWithImageData:
                guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.ActionWithImageData
                else { return }
                data.onSelect()
            case is ViewState.EmergencyData:
                guard
                    let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.EmergencyData
                else { return }
                data.onSelect()
            default:
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}
