//
//  RouteSettingsView.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 07.09.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class RouteSettingsView : BasePanBackgroundView {

    struct ViewState        {
        let sections        : [Section]
        let onClose         : (()->())
        let onSave          : (()->())
        
        struct RouteOption : _StandartImageSubtitle  {
            var image       : UIImage?
            var imageUrl    : String?
            var title       : String
            var descr       : String
            let isActivated : Bool
            let onSelect    : (()->())
        }
        
        struct LineOption : _Standart {
            var font  : UIFont?
            var title : String
            var color : UIColor?
            let isActivated : Bool
            let onSelect    : (()->())
        }
        
        static let initial = ViewState(sections: [], onClose: {}, onSave: {})
    }
    
    var viewState : ViewState = .initial {
        didSet {
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
            }
        }
    }
    
    private let closeButton: UIButton = {
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.setBackgroundImage(#imageLiteral(resourceName: "close_pan"), for: .normal)
        return closeButton
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .mm_Headline_3
        titleLabel.text = NSLocalizedString("Routes settings", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        titleLabel.textColor = .mm_TextPrimary
        titleLabel.adjustsFontSizeToFitWidth = true
        
        return titleLabel
    }()

    public let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.register(DisclaimerTableCell.nib,     forCellReuseIdentifier: DisclaimerTableCell.identifire)
        tableView.register(StandartCell.nib,    forCellReuseIdentifier: StandartCell.identifire)
        tableView.register(DefaultCellSubtitleCell.nib, forCellReuseIdentifier: DefaultCellSubtitleCell.identifire)
        tableView.register(StandartImageSubtitleCell.nib, forCellReuseIdentifier: StandartImageSubtitleCell.identifire)

        tableView.estimatedRowHeight = 50.0
        tableView.estimatedSectionHeaderHeight = 24
        tableView.sectionFooterHeight = 24
        return tableView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Save", tableName: nil, bundle: .mm_Map, value: "", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mm_Main
        button.roundCorners(.all, radius: 8)
        button.titleLabel?.font = UIFont(name: "MoscowSans-Medium", size: 15)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RouteSettingsView {
    
    @objc
    private func handleSave() {
        viewState.onSave()
    }

    private func setup() {
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
        closeButton.pin(on: self, {[
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: -20),
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24),
            $0.widthAnchor.constraint(equalToConstant: 24),
            $0.heightAnchor.constraint(equalToConstant: 24)
        ]})
        
        titleLabel.pin(on: self, {[
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 20),
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24),
            $0.rightAnchor.constraint(equalTo: closeButton.leftAnchor, constant: -8)
        ]})
        
        saveButton.pin(on: self, {[
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 20),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: -20),
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            $0.heightAnchor.constraint(equalToConstant: 44)
        ]})
        
        tableView.pin(on: self, {[
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10)
        ]})
    }
    
    @objc
    private func close() {
        viewState.onClose()
    }
}

extension RouteSettingsView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewState.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewState.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewState.sections[indexPath.section].rows[indexPath.row] {
        case is ViewState.LineOption:
            guard let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.LineOption,
                  let cell = tableView.dequeueReusableCell(withIdentifier: StandartCell.identifire, for: indexPath) as? StandartCell
            else { return UITableViewCell() }
            cell.configure(with: data)
            cell.tintColor = .mm_Main
            cell.accessoryType = data.isActivated ? .checkmark : .none
            return cell
        case is ViewState.RouteOption:
            guard let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.RouteOption,
                  let cell = tableView.dequeueReusableCell(withIdentifier: StandartImageSubtitleCell.identifire, for: indexPath) as? StandartImageSubtitleCell
            else { return UITableViewCell() }
            cell.configure(with: data)
            cell.tintColor = .mm_Main
            cell.accessoryType = data.isActivated ? .checkmark : .none
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension RouteSettingsView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sectionTitle = viewState.sections[section].title {
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 26))
            let label = UILabel(frame: CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width-20, height: 18))
            label.text = sectionTitle
            label.font = .mm_Body_15_Bold
            label.textColor = .mm_TextSecondary
            backgroundView.addSubview(label)
            return backgroundView
        } else { return nil }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if viewState.sections[section].title != nil {
            return 26
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewState.sections[indexPath.section].rows[indexPath.row] {
        case is ViewState.LineOption:
            guard let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.LineOption
            else { return }
            data.onSelect()
        case is ViewState.RouteOption:
            guard let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.RouteOption
            else { return }
            data.onSelect()
        default:
            break
        }
    }
}
