//
//  StationView.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 13.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class StationView : BasePanBackgroundView {
    
    struct ViewState {

        let stationTitle: String
        var sections: [Section]
        let onClose: (()-> ())
        
        struct ActionDat         : _ActionData {
            var color      : UIColor
            var title      : String
            var subtitle   : String
            var rightImage : UIImage
            var onSelect   : (()->())
        }
        
        struct ActionSubtitleData : _ActionSubtitleCell {
            var color      : UIColor
            var title      : String
            var subtitle   : String
            var rightImage : UIImage
            var onSelect   : (()->())
        }
        
        struct ActionsRow {
            let isMCD: Bool
            let onTransport : (()->())?
            let onBookmark  : (()->())?
            let bookmarkImage: UIImage
            let bookmarkTitle: String
            let onTrains: (()->())?
            let onMCD: (()->())?
        }
        
        struct MCDScheduleRow : _StandartImage {
            var title        : String
            var leftImage    : UIImage?
            var separator    : Bool
            let onSelect     : (() -> ())
        }
        
        struct WorktimeData : _Standart {
            var font  : UIFont?
            var title : String
            var color : UIColor?
        }
        
        struct Standart : _Standart {
            var font  : UIFont?
            var title : String
            var color : UIColor?
            let subtitle : String?
            let onSelect : (()->())
        }
        
        struct LineData {
            let lineIcon: UIImage
            let lineName: String
        }
        
        enum MCDArriving {
            case error(ErrorData)
            case loading
            case loaded(MCDArrivalTableViewCell.ViewState)
            
            struct ErrorData {
                let title: String
                let subtitle: String
                let image: UIImage
            }
        }
        
        enum TrainsWorkloadData {
            case error(ErrorData)
            case loading
            case loaded(WagonsLoadTableViewCell.ViewState)
            
            struct ErrorData {
                let title: String
                let subtitle: String
                let image: UIImage
            }
        }
        
        struct TrainsLastUpdate : _LastUpdate {
            var title          : String
        }
        
        struct WorkloadInfo {
            let text: String
            let onSelect: () -> ()
        }
        
        struct SubtitleData : _StandartImageSubtitle {
            var image      : UIImage?
            var imageUrl   : String?
            var title      : String
            var descr      : String
            let onSelect   : () -> ()
        }
        
        struct EmergencyData : _Emergency {
            var leftIcon: UIImage
            var title: String
            var description: String
            var backgroundColor: UIColor
            var textColor: UIColor
            var onSelect: () -> ()
        }
        
        struct Divider { }
        
        static let initial = ViewState(stationTitle: "Station", sections: [], onClose: {})
    }
    
    public var viewState: ViewState = .initial {
        didSet {
            render()
        }
    }
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .mm_Headline_3
        titleLabel.text = "Менделеевская"
        titleLabel.textColor = .mm_TextPrimary
        titleLabel.adjustsFontSizeToFitWidth = true
        return titleLabel
    }()
    
    private let closeButton: UIButton = {
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.setBackgroundImage(UIImage(named: "close_pan", in: .mm_Map, compatibleWith: nil), for: .normal)
        return closeButton
    }()
    
    public let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.estimatedRowHeight = 50.0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StationView {
    
    private func setupConstraints() {
        closeButton.pin(on: self, {[
            $0.widthAnchor.constraint(equalToConstant: 24),
            $0.heightAnchor.constraint(equalToConstant: 24),
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: -20)
        ]})
        titleLabel.pin(on: self, {[
            $0.topAnchor    .constraint(equalTo: $1.topAnchor,            constant: 24),
            $0.leftAnchor   .constraint(equalTo: $1.leftAnchor,           constant: 20),
            $0.rightAnchor  .constraint(equalTo: closeButton.leftAnchor,  constant: -8)
        ]})
        tableView.pin(on: self, {[
            $0.topAnchor    .constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            $0.leftAnchor   .constraint(equalTo: $1.leftAnchor,           constant: 0),
            $0.rightAnchor  .constraint(equalTo: $1.rightAnchor,          constant: 0),
            $0.bottomAnchor .constraint(equalTo: $1.bottomAnchor,         constant: -10)
        ]})
    }
    
    private func setup() {
        self.setupConstraints()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ActionCell.nib,                  forCellReuseIdentifier: ActionCell.identifire)
        self.tableView.register(StandartCell.nib,                forCellReuseIdentifier: StandartCell.identifire)
        self.tableView.register(EmergencyCell.nib,               forCellReuseIdentifier: EmergencyCell.identifire)
        self.tableView.register(NewEmergencyCell.nib,            forCellReuseIdentifier: NewEmergencyCell.identifire)
        self.tableView.register(StandartImageCell.nib,           forCellReuseIdentifier: StandartImageCell.identifire)
        self.tableView.register(ActionSubtitleCell.nib,          forCellReuseIdentifier: ActionSubtitleCell.identifire)
        self.tableView.register(FeatureTableViewCell.nib,        forCellReuseIdentifier: FeatureTableViewCell.identifire)
        self.tableView.register(LoadingTableViewCell.nib,        forCellReuseIdentifier: LoadingTableViewCell.identifire)
        self.tableView.register(StationLineTableCell.nib,        forCellReuseIdentifier: StationLineTableCell.identifire)
        self.tableView.register(DividerTableViewCell.nib,        forCellReuseIdentifier: DividerTableViewCell.identifire)
        self.tableView.register(DefaultCellSubtitleCell.nib,     forCellReuseIdentifier: DefaultCellSubtitleCell.identifire)
        self.tableView.register(MCDArrivalTableViewCell.nib,     forCellReuseIdentifier: MCDArrivalTableViewCell.identifire)
        self.tableView.register(WagonsLoadTableViewCell.nib,     forCellReuseIdentifier: WagonsLoadTableViewCell.identifire)
        self.tableView.register(LastUpdateTableViewCell.nib,     forCellReuseIdentifier: LastUpdateTableViewCell.identifire)
        self.tableView.register(SmallButtonTableViewCell.nib,    forCellReuseIdentifier: SmallButtonTableViewCell.identifire)
        self.tableView.register(StandartImageSubtitleCell.nib,   forCellReuseIdentifier: StandartImageSubtitleCell.identifire)
        self.tableView.register(SmallPlaceholderTableCell.nib,   forCellReuseIdentifier: SmallPlaceholderTableCell.identifire)
        self.tableView.register(StationActionsTableViewCell.nib, forCellReuseIdentifier: StationActionsTableViewCell.identifire)
    }
    
    private func render() {
        self.titleLabel.text = self.viewState.stationTitle
    }
    
    @objc
    private func close() {
        self.viewState.onClose()
    }
}

extension StationView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewState.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewState.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewState.sections[indexPath.section].rows[indexPath.row] {
        case is ViewState.ActionSubtitleData:
            guard
            let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.ActionSubtitleData,
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionSubtitleCell.identifire, for: indexPath) as? ActionSubtitleCell
            else { return UITableViewCell() }
            cell.configure(with: data)
            return cell
        case is ViewState.ActionDat:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.ActionDat,
                let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifire, for: indexPath) as? ActionCell
            else { return UITableViewCell() }
            cell.configure(with: data)
            return cell
        case is ViewState.LineData:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.LineData,
                let cell = tableView.dequeueReusableCell(withIdentifier: StationLineTableCell.identifire, for: indexPath) as? StationLineTableCell
            else { return UITableViewCell() }
            cell.leftImageView.image = data.lineIcon
            cell.mainTitleLabel.text = data.lineName
            return cell
        case is ViewState.SubtitleData:
            guard
            let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.SubtitleData,
            let cell = tableView.dequeueReusableCell(withIdentifier: StandartImageSubtitleCell.identifire, for: indexPath) as? StandartImageSubtitleCell
            else { return UITableViewCell() }
            cell.configure(with: data)
            return cell
        case is FeatureTableViewCell.ViewState:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? FeatureTableViewCell.ViewState,
                let cell = tableView.dequeueReusableCell(withIdentifier: FeatureTableViewCell.reuseID, for: indexPath) as? FeatureTableViewCell
            else { return UITableViewCell() }
            cell.viewState = data
            return cell
        case is ViewState.Standart:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.Standart
            else { return UITableViewCell() }
            if let subtitle = data.subtitle {
                guard
                let cell = tableView.dequeueReusableCell(withIdentifier: DefaultCellSubtitleCell.identifire, for: indexPath) as? DefaultCellSubtitleCell
                else { return UITableViewCell() }
                cell.mainTitleLabel.text = data.title
                cell.subtTitleLabel.text = subtitle
                return cell
            } else {
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: StandartCell.identifire, for: indexPath) as? StandartCell
                else { return UITableViewCell() }
                cell.configure(with: data)
                return cell
            }
        case is ViewState.MCDArriving:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.MCDArriving
            else { return UITableViewCell() }
            switch data {
            case .error(let errorData):
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: SmallPlaceholderTableCell.identifire, for: indexPath) as? SmallPlaceholderTableCell
                else { return UITableViewCell() }
                cell.mainImageView.image = errorData.image
                cell.mainTitleLabel.text = errorData.title
                cell.descLabel.text = errorData.subtitle
                return cell
            case .loading:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.identifire, for: indexPath) as? LoadingTableViewCell
                else { return UITableViewCell() }
                return cell
            case .loaded(let cellState):
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: MCDArrivalTableViewCell.identifire, for: indexPath) as? MCDArrivalTableViewCell
                else { return UITableViewCell() }
                cell.viewState = cellState
                return cell
            }
        case is ViewState.MCDScheduleRow:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.MCDScheduleRow,
                let cell = tableView.dequeueReusableCell(withIdentifier: StandartImageCell.identifire, for: indexPath) as? StandartImageCell
            else { return UITableViewCell() }
            cell.configure(with: data)
            return cell
        case is ViewState.TrainsWorkloadData:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.TrainsWorkloadData
            else { return UITableViewCell() }
            switch data {
            case .error(let errorData):
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: SmallPlaceholderTableCell.identifire, for: indexPath) as? SmallPlaceholderTableCell
                else { return UITableViewCell() }
                cell.mainImageView.image = errorData.image
                cell.mainTitleLabel.text = errorData.title
                cell.descLabel.text = errorData.subtitle
                return cell
            case .loading:
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.identifire, for: indexPath) as? LoadingTableViewCell
                else { return UITableViewCell() }
                return cell
            case .loaded(let cellState):
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: WagonsLoadTableViewCell.identifire, for: indexPath) as? WagonsLoadTableViewCell
                else { return UITableViewCell() }
                cell.viewState = cellState
                return cell
            }
        case is ViewState.TrainsLastUpdate:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.TrainsLastUpdate,
                let cell = tableView.dequeueReusableCell(withIdentifier: LastUpdateTableViewCell.identifire, for: indexPath) as? LastUpdateTableViewCell
            else { return UITableViewCell() }
            cell.configure(with: data)
            return cell
        case is ViewState.WorkloadInfo:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.WorkloadInfo,
                let cell = tableView.dequeueReusableCell(withIdentifier: SmallButtonTableViewCell.identifire, for: indexPath) as? SmallButtonTableViewCell
            else { return UITableViewCell() }
            cell.mainButton.setTitle(data.text, for: .normal)
            cell.onSelect = data.onSelect
            return cell
        case is ViewState.EmergencyData:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.EmergencyData,
                let cell = tableView.dequeueReusableCell(withIdentifier: NewEmergencyCell.identifire, for: indexPath) as? NewEmergencyCell
            else { return UITableViewCell() }
            cell.configure(with: data)
            return cell
        case is ViewState.Divider:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: DividerTableViewCell.identifire, for: indexPath) as? DividerTableViewCell
            else { return UITableViewCell() }
            return cell
        case is ViewState.WorktimeData:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.WorktimeData,
                let cell = tableView.dequeueReusableCell(withIdentifier: StandartCell.identifire, for: indexPath) as? StandartCell
            else { return UITableViewCell() }
            cell.configure(with: data)
            return cell
        case is ViewState.ActionsRow:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.ActionsRow,
                let cell = tableView.dequeueReusableCell(withIdentifier: StationActionsTableViewCell.identifire, for: indexPath) as? StationActionsTableViewCell
            else { return UITableViewCell() }
            cell.viewState = data
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension StationView : UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewState.sections[indexPath.section].rows[indexPath.row] {
        case is ViewState.EmergencyData:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.EmergencyData
            else { return }
            data.onSelect()
        case is ViewState.ActionSubtitleData:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.ActionSubtitleData
            else { return }
            data.onSelect()
        case is ViewState.Standart:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.Standart
            else { return }
            data.onSelect()
        case is ViewState.MCDScheduleRow:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.MCDScheduleRow
            else { return }
            data.onSelect()
        case is ViewState.SubtitleData:
            guard
                let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.SubtitleData
            else { return }
            data.onSelect()
        default:
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sectionTitle = viewState.sections[section].title {
            let header = LargeSectionHeader.loadFromNib()
            header.titleLabel.text = sectionTitle
            return header
        } else { return nil }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if viewState.sections[section].title != nil {
            return 40
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
}
