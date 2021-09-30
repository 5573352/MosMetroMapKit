//
//  DetailArticleView.swift
//
//  Created by Сеня Римиханов on 10.08.2020.
//

import UIKit

class DetailArticleView: UIView {
    
    var onNavbarHide : (()->())?
    var onNavbarShow : (()->())?

    // TODO: переписать стжйт на структуру
    enum ViewState               {
        case error
        case loading
        case loaded (ViewData)
        
        struct ViewData          {
            let items           : [Section]
            let backgroundColor : UIColor
        }
        
        struct ImageRow          {
            let imageURL        : String
        }
        
        struct TitleRow          {
            let text            : String
            let textColor       : UIColor
        }
        
        struct BodyRow           {
            let text            : NSAttributedString
            let textColor       : UIColor
        }
        
        struct HTMLBodyRow       {
            let htmlText        : NSAttributedString
        }
        
        struct ConnectionRow     {
            let sourceName      : String
            let sourceLineIcon  : UIImage
            let destinationName : String
            let destinationIcon : UIImage
        }
    }
    
    var viewState: ViewState = .loading {
        didSet {
            self.tableView.reloadData()
        }
    }

    // TODO: UINib -> .nib
    public let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.register(NewsBodyCell.nib, forCellReuseIdentifier: NewsBodyCell.identifire)
        tableView.register(NewsImageCell.nib, forCellReuseIdentifier: NewsImageCell.identifire)
        tableView.register(NewsTitleCell.nib, forCellReuseIdentifier: NewsTitleCell.identifire)
        tableView.register(NewsStationCell.nib, forCellReuseIdentifier: NewsStationCell.identifire)
        tableView.register(NewsHTMLTableCell.nib, forCellReuseIdentifier: NewsHTMLTableCell.identifire)
        tableView.register(LoadingTableViewCell.nib, forCellReuseIdentifier: LoadingTableViewCell.identifire)

        tableView.estimatedRowHeight           = 48.0
        tableView.estimatedSectionHeaderHeight = 24
        tableView.sectionFooterHeight          = 12
        tableView.sectionHeaderHeight          = 12
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

extension DetailArticleView {
    private func setup() {
        backgroundColor = .mm_Base
        tableView.delegate = self
        tableView.dataSource = self
        tableView.pin(on: self, {[
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 0),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 0),
        ]})
    }
}

extension DetailArticleView: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pan = scrollView.panGestureRecognizer
        let velocity = pan.velocity(in: scrollView).y
        if velocity < -5 {
            self.onNavbarShow?()
        } else if velocity > 5 {
            self.onNavbarHide?()
        }
    }
}

extension DetailArticleView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewState {
        case .error:
            return 1
        case .loading:
            return 1
        case .loaded(let data):
            return data.items[section].rows.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch viewState {
        case .error:
            return 1
        case .loading:
            return 1
        case .loaded(let data):
            return data.items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewState {
        case .error:
            return UITableViewCell()
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.identifire, for: indexPath) as! LoadingTableViewCell
            return cell
        case .loaded(let data):
            switch data.items[indexPath.section].rows[indexPath.row] {
            case is ViewState.ImageRow:
                let data = data.items[indexPath.section].rows[indexPath.row] as! ViewState.ImageRow
                let cell = tableView.dequeueReusableCell(withIdentifier: NewsImageCell.reuseID, for: indexPath) as! NewsImageCell
                cell.imageURL = data.imageURL
                cell.onSet = { [weak self] in
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                }
                return cell
            case is ViewState.TitleRow:
                let data = data.items[indexPath.section].rows[indexPath.row] as! ViewState.TitleRow
                let cell = tableView.dequeueReusableCell(withIdentifier: NewsTitleCell.identifire, for: indexPath) as! NewsTitleCell
                cell.mainLabel.text = data.text
                cell.mainLabel.textColor = data.textColor
                return cell
            case is ViewState.BodyRow:
                let data = data.items[indexPath.section].rows[indexPath.row] as! ViewState.BodyRow
                let cell = tableView.dequeueReusableCell(withIdentifier: NewsBodyCell.identifire, for: indexPath) as! NewsBodyCell
                cell.mainLabel.attributedText = data.text
                return cell
            case is ViewState.HTMLBodyRow:
                let data = data.items[indexPath.section].rows[indexPath.row] as! ViewState.HTMLBodyRow
                let cell = tableView.dequeueReusableCell(withIdentifier: NewsHTMLTableCell.identifire, for: indexPath) as! NewsHTMLTableCell
                cell.textView.attributedText = data.htmlText
                return cell
            case is NewsStationCell.ViewState:
                let data = data.items[indexPath.section].rows[indexPath.row] as! NewsStationCell.ViewState
                let cell = tableView.dequeueReusableCell(withIdentifier: NewsStationCell.identifire, for: indexPath) as! NewsStationCell
                cell.configure(data)
                return cell
            case is ViewState.ConnectionRow:
                return UITableViewCell()
            default:
                return UITableViewCell()
            }
        }
    }
}
