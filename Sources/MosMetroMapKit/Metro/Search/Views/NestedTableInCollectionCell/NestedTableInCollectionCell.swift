//
//  NestedTableInCollectionCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 02.09.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class NestedTableInCollectionCell: UICollectionViewCell {
    
    static let reuseID = "NestedTableInCollectionCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    var onScroll: (()->())?
    
    // TODO: - Переписать под структуру + добавить новые
    enum ViewState {
        
        case error
        case loading
        case loaded([Any])
        
        struct Category    : _StandartImage {
            var title     : String
            var leftImage : UIImage?
            var separator : Bool
            let onSelect  : () -> ()
        }
        
        struct History     : _StandartImage{
            var title: String
            var leftImage: UIImage?
            var separator: Bool
            let subtitle: String?
            let onSelect: () -> ()
        }
        
        struct SearchItem  : _StandartImage {
            var title     : String
            var leftImage : UIImage?
            var separator : Bool
            let subtitle  : String?
            let distance  : String?
            let onSelect  : () -> ()
        }
        
        struct FavoritesItem : _StandartImageSubtitle {
            var image       : UIImage?
            var imageUrl    : String?
            var title       : String
            var descr       : String
            let onSelect    : () -> ()
            let onRemove    : (Int) -> ()
        }
        
        struct Placeholder {
            let image: UIImage
            let title: String
            let subtitle: String
        }
    }
    
    public var viewState: ViewState = .loading {
        didSet {
            tableView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.separatorColor = .clear
        tableView.backgroundColor = .mm_Base
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 40
        tableView.register(StandartImageCell.nib, forCellReuseIdentifier: StandartImageCell.identifire)
        tableView.register(CitySearchItemCell.nib, forCellReuseIdentifier: CitySearchItemCell.identifire)
        tableView.register(LoadingTableViewCell.nib, forCellReuseIdentifier: LoadingTableViewCell.identifire)
        tableView.register(ImagePlaceholderTableCell.nib, forCellReuseIdentifier: ImagePlaceholderTableCell.identifire)
        tableView.register(StandartImageSubtitleCell.nib, forCellReuseIdentifier: StandartImageSubtitleCell.identifire)
        tableView.register(StationSearchEmergencyCell.nib, forCellReuseIdentifier: StationSearchEmergencyCell.identifire)
    }
}

extension NestedTableInCollectionCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewState {
        case .error:
            return 1
        case .loading:
            return 1
        case .loaded(let items):
            return items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewState {
        case .error:
            return UITableViewCell()
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.identifire, for: indexPath) as! LoadingTableViewCell
            return cell
        case .loaded(let items):
            switch items[indexPath.row] {
            case is ViewState.Category:
                guard let item = items[safe: indexPath.row] as? ViewState.Category else { return UITableViewCell() }
                let cell = tableView.dequeueReusableCell(withIdentifier: StandartImageCell.identifire, for: indexPath) as! StandartImageCell
                cell.configure(with: item)
                return cell
            case is ViewState.FavoritesItem:
                guard let item = items[safe: indexPath.row] as? ViewState.FavoritesItem else { return UITableViewCell() }
                let cell = tableView.dequeueReusableCell(withIdentifier: StandartImageSubtitleCell.identifire, for: indexPath) as! StandartImageSubtitleCell
                cell.configure(with: item)
//                cell.leftImage.image = item.image
//                cell.title.text = item.name
//                cell.secondary.text = item.subtitle
                return cell
            case is ViewState.SearchItem:
                guard let item = items[safe: indexPath.row] as? ViewState.SearchItem else { return UITableViewCell() }
                if let subtitle = item.subtitle {
                    let cell = tableView.dequeueReusableCell(withIdentifier: CitySearchItemCell.reuseID, for: indexPath) as! CitySearchItemCell
                    cell.leftImageView.image = item.leftImage
                    cell.mainTitleLabel.text = item.title
                    cell.subtitleLabel.text = subtitle
                    cell.rightLabel.text = item.distance
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: StandartImageCell.identifire, for: indexPath) as! StandartImageCell
                    cell.configure(with: item)
                    return cell
                }
            case is ViewState.History:
                guard let item = items[safe: indexPath.row] as? ViewState.History else { return UITableViewCell() }
                if let subtitle = item.subtitle {
                    let cell = tableView.dequeueReusableCell(withIdentifier: CitySearchItemCell.reuseID, for: indexPath) as! CitySearchItemCell
                    cell.leftImageView.image = item.leftImage
                    cell.mainTitleLabel.text = item.title
                    cell.subtitleLabel.text = subtitle
                    cell.rightLabel.text = nil
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: StandartImageCell.identifire, for: indexPath) as! StandartImageCell
                    cell.configure(with: item)
                    return cell
                }
            case is MetroSearchView.ViewState.StationViewData:
                guard let data = items[safe: indexPath.row] as? MetroSearchView.ViewState.StationViewData else { return UITableViewCell() }
                if let emergency = data.emergency {
                    let cell = tableView.dequeueReusableCell(withIdentifier: StationSearchEmergencyCell.identifire, for: indexPath) as! StationSearchEmergencyCell
                    cell.leftImageView.image = data.image
                    cell.mainTitleLabel.text = data.title
                    cell.subTitleLabel.text = data.descr
                    cell.emergencyIcon.image = emergency.image
                    cell.emergencyMessageLabel.text = emergency.message
                    cell.emergencyIcon.tintColor = emergency.tintColor
                    cell.emergencyMessageLabel.textColor = emergency.tintColor
                    cell.separatorView.isHidden = false
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: StandartImageSubtitleCell.identifire, for: indexPath) as! StandartImageSubtitleCell
                    cell.configure(with: data)
                    return cell
                }
            case is ViewState.Placeholder:
                guard let data = items[safe: indexPath.row] as? ViewState.Placeholder else { return UITableViewCell() }
                let cell = tableView.dequeueReusableCell(withIdentifier: ImagePlaceholderTableCell.identifire, for: indexPath) as! ImagePlaceholderTableCell
                cell.placeholderImageView.image = data.image
                cell.placeholderTitleLabel.text = data.title
                cell.placeholderSubtitleLabel.text = data.subtitle
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
}

extension NestedTableInCollectionCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .loaded(let items) = viewState {
            switch items[indexPath.row] {
            case is ViewState.Category:
                guard let item = items[safe: indexPath.row] as? ViewState.Category else { return }
                item.onSelect()
            case is ViewState.FavoritesItem:
                guard let item = items[safe: indexPath.row] as? ViewState.FavoritesItem else { return }
                item.onSelect()
            case is ViewState.SearchItem:
                guard let item = items[safe: indexPath.row] as? ViewState.SearchItem else { return }
                item.onSelect()
            case is ViewState.History:
                guard let item = items[safe: indexPath.row] as? ViewState.History else { return }
                item.onSelect()
            case is MetroSearchView.ViewState.StationViewData:
                guard let item = items[safe: indexPath.row] as? MetroSearchView.ViewState.StationViewData else { return }
                item.onSelect()
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if case .loaded(let items) = viewState {
            switch items[indexPath.row] {
            case is ViewState.Category:
                return false
            case is ViewState.FavoritesItem:
                return true
            case is ViewState.SearchItem:
                return false
            case is ViewState.History:
                return false
            case is MetroSearchView.ViewState.StationViewData:
                let item = items[indexPath.row] as! MetroSearchView.ViewState.StationViewData
                if let _ = item.onRemove {
                    return true
                } else {
                    return false
                }
            
            default:
                return false
            }
        }
        return false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.onScroll?()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if case .loaded(let items) = viewState {
            switch items[indexPath.row] {
            case is ViewState.FavoritesItem:
                let deleteAction = UITableViewRowAction(style: .default, title: NSLocalizedString("Remove", tableName: nil, bundle: .mm_Map, value: "", comment: ""), handler: { (action, indexPath) in
                    guard let item = items[safe: indexPath.row] as? ViewState.FavoritesItem else { return }
                    item.onRemove(indexPath.row)
                })
                deleteAction.backgroundColor = .mm_Red
                return [deleteAction]
            case is MetroSearchView.ViewState.StationViewData:
                guard let item = items[safe: indexPath.row] as? MetroSearchView.ViewState.StationViewData else { return nil }
                if let onRemove = item.onRemove {
                    let deleteAction = UITableViewRowAction(style: .default, title: NSLocalizedString("Remove", tableName: nil, bundle: .mm_Map, value: "", comment: ""), handler: { (action, indexPath) in
                        onRemove()
                    })
                    deleteAction.backgroundColor = .mm_Red
                    return [deleteAction]
                }
            default:
                return nil
            }
        }
        return nil        
    }
}
