//
//  DetailArticleController.swift
//
//  Created by Павел Кузин on 27.04.2021.
//

import UIKit

class DetailArticleController: BaseController {
    
    private let detailView = DetailArticleView(frame: UIScreen.main.bounds)
    public var service : MetroService?
    var model: Any? {
        didSet {
            makeState(callback: { [weak self] state in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.detailView.viewState = state
                }
            })
        }
    }
    
    override func loadView() {
        super.loadView()
        view = detailView
        detailView.onNavbarShow = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
        }
        self.navigationController?.navigationBar.prefersLargeTitles = false
        detailView.onNavbarHide = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       self.navigationController?.navigationBar.isTranslucent = true
        detailView.viewState = .loading
        makeState(callback: { [weak self] state in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.detailView.viewState = state
            }
        })
    }
    
    private func makeState(callback: @escaping (DetailArticleView.ViewState) -> ()) {
        switch model{
        case is Int:
             break
        case is Article:
            break
        case is Emergency:
            DispatchQueue.global(qos: .userInitiated).async {
                let emergency = self.model as! Emergency
                var headerRows = [Any]()
                let mainTitleRow = DetailArticleView.ViewState.TitleRow(text: emergency.title, textColor: .mm_TextPrimary)
                headerRows.append(mainTitleRow)
                if let desc = emergency.description {
                    let descRow = DetailArticleView.ViewState.BodyRow(text: self.toAttributed(desc), textColor: .mm_TextPrimary)
                    headerRows.append(descRow)
                }
                let headerSection = Section(title: nil, isNeedToExpand: false, isExpanded: true, rows: headerRows, onExpandTap: nil)
                
                let stationRows: [NewsStationCell.ViewState] = emergency.stations.compactMap { stationEmergency in
                    guard let station = self.service?.stations.filter({ $0.id == stationEmergency.id }).first else { return nil }
                    return NewsStationCell.ViewState(title           : station.name,
                                                     lineIcon        : station.line.originalIcon,
                                                     lineName        : station.line.name,
                                                     statusIcon      : self.iconFor(emergency: stationEmergency),
                                                     statusTintColor : self.colorFor(emergency: stationEmergency),
                                                     statusMessage   : stationEmergency.title)
                }
                let stationSection = Section(title: "Станции", isNeedToExpand: false, isExpanded: true, rows: stationRows, onExpandTap: nil)
                callback(.loaded(DetailArticleView.ViewState.ViewData(items: [headerSection,stationSection], backgroundColor: .black)))
            }
        default:
            break
        }
    }
    
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
       
    private func toAttributed(_ plainText: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: plainText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: UIColor.mm_TextPrimary], range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    private func stateForContent(contentBlock: Article.Content, textColor: UIColor) -> Any {
        switch contentBlock.type {
        case .title:
            return DetailArticleView.ViewState.TitleRow(text: contentBlock.content, textColor: textColor)
        case .image:
            return DetailArticleView.ViewState.ImageRow(imageURL: contentBlock.content)
        case .text:
            return DetailArticleView.ViewState.BodyRow(text: toAttributed(contentBlock.content), textColor: textColor)
        case .html:
            return DetailArticleView.ViewState.HTMLBodyRow(htmlText: Utils.convert(html: contentBlock.content))
        }
    }
    
    private func colorFor(emergency: Emergency.StationEmergency) -> UIColor {
        switch emergency.status {
        case .closed:
            return UIColor.mm_Red
        case .emergency:
            return UIColor.mm_Warning
        case .info:
            return UIColor.mm_Information
        }
    }
}
