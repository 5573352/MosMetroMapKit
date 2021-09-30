//
//  MetroSearchView.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 12.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//
// swiftlint:disable all
// TODO: переписать экран под красивую логику

import UIKit

class MetroSearchView: UIView {
    
    var onScroll: (()->())?
    var onSegmentSelect: ((Int) -> ())?
    
    var states: [NestedTableInCollectionCell.ViewState] = [.loading, .loading] {
        didSet {
            collectionView.reloadData()
        }
    }

    enum ViewState {
        case searching ([StationViewData])
        case standart
        
        struct StationViewData : _StandartImageSubtitle {
            var image         : UIImage?
            var imageUrl      : String?
            var title         : String
            var descr         : String
            let onSelect      : (()->())
            let onRemove      : (()->())?
            let emergency     : EmergencyData?
            
            struct EmergencyData {
                let image     : UIImage
                let message   : String
                let tintColor : UIColor
            }
        }
    }
    
    var viewState: ViewState = .standart {
        didSet {
            switch viewState {
            case .searching :
                tableView.reloadData()
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    guard let self = self else { return }
                    self.stackView.alpha          = 0
                    self.searchResultsLabel.alpha = 1
                    self.collectionView.alpha     = 0
                    self.tableView.alpha          = 1
                })
            case .standart  :
                collectionView.reloadData()
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    guard let self = self else { return }
                    self.stackView.alpha          = 1
                    self.searchResultsLabel.alpha = 0
                    self.collectionView.alpha     = 1
                    self.tableView.alpha          = 0
                })
            }
        }
    }
    
    private let favoriteStationsButton: UnderlineButton = {
        let button = UnderlineButton()
        button.setTitle("Favorites".localized(), for: .normal)
        button.isSetted = true
        return button
    }()
    
    private let latestRoutesButton: UnderlineButton = {
        let button = UnderlineButton()
        button.setTitle("History".localized(), for: .normal)
        button.isSetted = false
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var tableView      : UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorColor = .clear
        table.backgroundColor = .mm_Base
        table.register(PlaceholderTableCell.nib,       forCellReuseIdentifier: PlaceholderTableCell.identifire)
        table.register(ImagePlaceholderTableCell.nib,  forCellReuseIdentifier: ImagePlaceholderTableCell.identifire)
        table.register(StandartImageSubtitleCell.nib,  forCellReuseIdentifier: StandartImageSubtitleCell.identifire)
        table.register(StationSearchEmergencyCell.nib, forCellReuseIdentifier: StationSearchEmergencyCell.identifire)

        return table
    }()
    
    private var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.register(NestedTableInCollectionCell.nib, forCellWithReuseIdentifier: NestedTableInCollectionCell.identifire)
        return collectionView
    }()

    private let searchResultsLabel: UILabel = {
        let label = UILabel()
        label.font = .mm_Body_15_Bold
        label.textColor = .mm_TextPrimary
        label.text = "Search results".localized()
        label.alpha = 0
        return label
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .mm_Base
        view.isOpaque = true
        view.roundCorners(.top, radius: 16)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .navigationBar
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MetroSearchView {

    private func setupButtons() {
        contentView.addSubview(stackView)
        stackView.pin(on: contentView, {[
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor, constant: 8),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 20),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: -20),
            $0.heightAnchor.constraint(equalToConstant: 48)
        ]})
        stackView.addArrangedSubview(favoriteStationsButton)
        stackView.addArrangedSubview(latestRoutesButton)
        favoriteStationsButton.addTarget(self, action: #selector(handleSegmentChange(_:)), for: .touchUpInside)
        latestRoutesButton.addTarget(self, action: #selector(handleSegmentChange(_:)), for: .touchUpInside)
    }

    private func setup() {
        addSubview(contentView)
        contentView.pin(on: self, {[
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor, constant: 0),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 0)
        ]})
        
        setupButtons()

        searchResultsLabel.pin(on: contentView, {[
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor, constant: 8),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 20),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: -20),
            $0.heightAnchor.constraint(equalToConstant: 48)
        ]})

        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alpha = 0
        tableView.pin(on: contentView, {[
            $0.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 0)
        ]})
        contentView.addSubview(collectionView)
        collectionView.pin(on: contentView, {[
            $0.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 0)
        ]})
    }
    
    @objc
    private func handleSegmentChange(_ sender: UnderlineButton) {
        if sender == favoriteStationsButton {
            self.favoriteStationsButton.isSetted = true
            self.latestRoutesButton.isSetted = false
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        } else {
            self.favoriteStationsButton.isSetted = false
            self.latestRoutesButton.isSetted = true
            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .right, animated: false)
        }
    }
}

extension MetroSearchView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if case .searching(_) = viewState{
            return 1
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .searching(let items) = viewState {
            if items.count == 0 {
                return 1
            } else {
                return items.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if case .searching(let items) = viewState {
            if items.count == 0 {
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: ImagePlaceholderTableCell.reuseID, for: indexPath) as? ImagePlaceholderTableCell
                else { return UITableViewCell() }
                cell.placeholderImageView.image = #imageLiteral(resourceName: "No search data")
                cell.placeholderTitleLabel.text = "We can not find station with given name".localized()
                cell.placeholderSubtitleLabel.text = "Try again with another name".localized()
                return cell
            } else {
                guard let data = items[safe: indexPath.row] else { return UITableViewCell() }
                if let emergency = data.emergency {
                    guard
                        let cell = tableView.dequeueReusableCell(withIdentifier: StationSearchEmergencyCell.identifire, for: indexPath) as? StationSearchEmergencyCell
                    else { return UITableViewCell() }
                    cell.leftImageView.image = data.image
                    cell.mainTitleLabel.text = data.title
                    cell.subTitleLabel.text = data.descr
                    cell.emergencyIcon.image = emergency.image
                    cell.emergencyMessageLabel.text = emergency.message
                    cell.emergencyIcon.tintColor = emergency.tintColor
                    cell.emergencyMessageLabel.textColor = emergency.tintColor
                    return cell
                } else {
                    guard
                        let cell = tableView.dequeueReusableCell(withIdentifier: StandartImageSubtitleCell.identifire, for: indexPath) as? StandartImageSubtitleCell
                    else { return UITableViewCell() }
                    cell.configure(with: data)
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
}

extension MetroSearchView: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.onScroll?()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .searching(let items) = viewState {
            guard let item = items[safe: indexPath.row] else { return }
            item.onSelect()
        }
    }
}

extension MetroSearchView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NestedTableInCollectionCell.identifire, for: indexPath) as? NestedTableInCollectionCell
        else { return UICollectionViewCell() }
        cell.onScroll = { [weak self] in
            self?.onScroll?()
        }
        cell.viewState = self.states[indexPath.row]
        return cell
    }
}

extension MetroSearchView: UICollectionViewDelegate { }

extension MetroSearchView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: collectionView.frame.height)
    }
}
