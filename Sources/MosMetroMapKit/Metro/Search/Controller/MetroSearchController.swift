//
//  MetroSearchController.swift
//
//  Created by Павел Кузин on 21.04.2021.
//

import UIKit
import SPAlert

class MetroSearchController : BaseController {
    
    private var filteredStations = [Station]()
    private let searchController = UISearchController(searchResultsController: nil)
    public let searchView = MetroSearchView(frame: UIScreen.main.bounds)
    
    var allStations: [Int : StationDTO] = [:] {
        didSet {
            makeClipState()
        }
    }
    var service : MetroService?
    
    public var onStationSelect: ((Station,Direction) -> ())?
    public var direction: Direction = .from {
        didSet {
            switch direction {
            case .to:
                searchController.searchBar.placeholder = NSLocalizedString("To", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            case .from:
                searchController.searchBar.placeholder = NSLocalizedString("From", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        view = searchView
        searchView.onScroll = { [weak self] in
            guard let self = self else { return }
            self.searchController.searchBar.endEditing(true)
        }
        setupSearchController()
        self.navigationItem.titleView = searchController.searchBar
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .navigationBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchController.isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        searchController.isActive = false
        searchController.searchBar.resignFirstResponder()
    }
    
    public func makeClipState() {
        guard let service = self.service else { return }
        let latestSearchedData = service.stations.map { station in
            return MetroSearchView.ViewState.StationViewData(image: station.line.originalIcon,
                                                             title: station.name,
                                                             descr: station.line.name,
                                                             onSelect: { [weak self] in
                                                                guard let self = self else { return }
                                                                self.handleStationSelection(station)
                                                             },
                                                             onRemove: nil,
                                                             emergency: nil)
        }
        self.searchView.viewState = .searching(latestSearchedData)
    }
}

extension MetroSearchController {
    
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    private func checkEmergency(on station: Station) -> MetroSearchView.ViewState.StationViewData.EmergencyData? {
        if !station.emergency.isEmpty {
            for em in station.emergency {
                var image = #imageLiteral(resourceName: "information_circle")
                var tintColor = UIColor.mm_Information
                switch em.status {
                case .closed:
                    image = #imageLiteral(resourceName: "closinggg")
                    tintColor = .mm_Red
                case .emergency:
                    image = #imageLiteral(resourceName: "alert")
                    tintColor = .mm_Warning
                case .info:
                    break
                }
                return MetroSearchView.ViewState.StationViewData.EmergencyData(image: image, message: em.title, tintColor: tintColor)
            }
        }
        return nil
    }
    
    private func handleStationSelection(_ station: Station) {
        if !station.emergency.isEmpty {
            for em in station.emergency {
                if em.status == .closed {
                    SPAlert.present(title: em.title, preset: .error)
                } else {
                    self.onStationSelect?(station,direction)
                    self.searchController.isActive = false
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            self.onStationSelect?(station,direction)
            self.searchController.isActive = false
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func handleSelection(_ station: StationDTO) {
        guard let service = self.service else { return }
        if let _station = service.stations.filter({ $0.id == station.id }).first {
            if !_station.emergency.isEmpty {
                for em in _station.emergency {
                    if em.status == .closed {
                        SPAlert.present(title: em.title, preset: .error)
                    } else {
                        self.onStationSelect?(_station,direction)
                        self.searchController.isActive = false
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                self.onStationSelect?(_station,direction)
                self.searchController.isActive = false
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if isFiltering() {
            var isRussian = true
            if (searchText.rangeOfCharacter(from: NSCharacterSet.init(charactersIn:"abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted) == nil) {
                isRussian = false
            }
            let results = allStations.values.filter { isRussian ? $0.name_ru.contains(searchText) : $0.name_en.contains(searchText) }
            let items: [MetroSearchView.ViewState.StationViewData] = results.map { station in
                return MetroSearchView.ViewState.StationViewData(
                    image: station.line?.originalImage ?? UIImage(named: "metro_logo_tempalte", in: .mm_Map, compatibleWith: nil),
                    title: station.name,
                    descr: station.line?.name ?? "",
                    onSelect: { [weak self] in
                       self?.handleSelection(station)
                    },
                    onRemove: nil,
                    emergency: nil
                )
            }
            self.searchView.viewState = .searching(items)
        } else {
            self.makeClipState()
        }
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.backgroundColor = .navigationBar
        searchController.searchBar.tintColor = .mm_TextPrimary
        searchController.searchBar.sizeToFit()
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.font = .mm_Body_17_Regular
            searchController.searchBar.searchTextField.backgroundColor = UIColor.black.withAlphaComponent(0.12)
            self.navigationItem.searchController?.searchBar.searchTextField.textColor = .mm_TextPrimary
            searchController.searchBar.searchTextField.textColor = .mm_TextPrimary
        }
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
}

extension MetroSearchController: UISearchResultsUpdating {
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension MetroSearchController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MetroSearchController: UISearchControllerDelegate {
    
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async { [unowned self] in
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
}

protocol OptionalType {
    associatedtype Wrapped
    func map<U>(_ f: (Wrapped) throws -> U) rethrows -> U?
}

extension Optional: OptionalType {}

extension Sequence where Iterator.Element: OptionalType {
    
    func removeNils() -> [Iterator.Element.Wrapped] {
        var result: [Iterator.Element.Wrapped] = []
        for element in self {
            if let element = element.map({ $0 }) {
                result.append(element)
            }
        }
        return result
    }
}
