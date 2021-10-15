//
//  MetroFilerView.swift
//
//  Created by Сеня Римиханов on 23.08.2020.
//

import UIKit

class MetroFilterView : BasePanBackgroundView {
    
    var onClose: (() -> ())?
    
    struct ViewState {
        let sections: [Section]
        
        struct Disclaimer {
            let title      : String
            let detailText : String
        }
        
        struct FilterOption {
            let title      : String
            let icon       : UIImage
            let onSelect   : (()->())
            let isSelected : Bool
        }
        
        static let initial = ViewState(sections: [])
    }
    
    struct ButtonsState : _FloatingButtons {
        var mainButtonTitle      : String
        var secondaryButtonTitle : String
        var onButtonTap          : ((ButtonType)->())
        
        static let initial = ButtonsState(mainButtonTitle: "", secondaryButtonTitle: "", onButtonTap: { _ in})
    }
    
    public var buttonsState: ButtonsState = .initial {
        didSet {
            self.floatingButtonsView.confugure(with: buttonsState)
        }
    }
    
    public var viewState: ViewState = .initial {
        didSet {
            tableView.reloadData()
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        titleLabel.text = NSLocalizedString("Filters", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        titleLabel.textColor = .mm_TextPrimary
        titleLabel.adjustsFontSizeToFitWidth = true
        
        return titleLabel
    }()
    
    private let floatingButtonsView = FloatingButtonsView.loadFromNib()
    
    public let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.estimatedRowHeight = 50
        tableView.sectionFooterHeight = 24
        tableView.estimatedSectionHeaderHeight = 24
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        tableView.register(DisclaimerTableCell.nib,   forCellReuseIdentifier: DisclaimerTableCell.identifire)
        tableView.register(ButtonTableViewCell.nib,   forCellReuseIdentifier: ButtonTableViewCell.identifire)
        tableView.register(FilterOptionTableCell.nib, forCellReuseIdentifier: FilterOptionTableCell.identifire)
        return tableView
    }()
}

extension MetroFilterView {
    
    @objc
    private func close() {
        onClose?()
    }
    
    private func setup() {
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
        
        tableView.pin(on: self, {[
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -30)
        ]})
        
        floatingButtonsView.pin(on: self, {[
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 20),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: -20),
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ]})
    }
}

extension MetroFilterView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let filter = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.FilterOption {
            filter.onSelect()
        }
    }
}

extension MetroFilterView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewState.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewState.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewState.sections[indexPath.section].rows[indexPath.row] {
        case is ViewState.Disclaimer:
            guard let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.Disclaimer,
                  let cell = tableView.dequeueReusableCell(withIdentifier: DisclaimerTableCell.reuseID, for: indexPath) as? DisclaimerTableCell
            else { return UITableViewCell()}
            cell.mainTitleLabel.text = data.title
            cell.descriptionLabel.text = data.detailText
            return cell
        case is ViewState.FilterOption:
            guard let data = viewState.sections[indexPath.section].rows[indexPath.row] as? ViewState.FilterOption,
                  let cell = tableView.dequeueReusableCell(withIdentifier: FilterOptionTableCell.reuseID, for: indexPath) as? FilterOptionTableCell
            else { return UITableViewCell()}
            cell.mainTitleLabel.text = data.title
            cell.leftImageView.image = data.icon
            cell.accessoryType = data.isSelected ? .checkmark : .none
            return cell
        default:
            return UITableViewCell()
        }
    }
}
