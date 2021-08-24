//
//  MetroMapController.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 13.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit
import SPAlert
import FloatingPanel

public class MetroMapController: BaseController {
    
    public var onRetry : (()->())?
    private var currentOption = 1
    
    private var stationFrom: Station? {
        didSet {
            let lastState = self.metroMapView.fieldsState
            if stationFrom != nil {
                let fromState = StationSelectTextField.ViewState(color: stationFrom!.line.color,
                                                                 image: stationFrom!.line.invertedIcon,
                                                                 title: stationFrom!.name,
                                                                 onTap: { },
                                                                 onClear: { [weak self] in self?.handleTextFieldClear(.from)} )
                self.metroMapView.fieldsState = FieldState(to: lastState.to, from: fromState)
                
            } else {
                
                self.metroMapView.fieldsState = FieldState(to: lastState.to, from: self.makeInitialFieldState().from)
            }
            if stationFrom != nil && stationTo != nil {
                self.findRoute()
            }
        }
    }
    
    private var stationTo: Station? {
        didSet {
            let lastState = self.metroMapView.fieldsState
            if stationTo != nil {
                let toState = StationSelectTextField.ViewState(color: stationTo!.line.color,
                                                               image: stationTo!.line.invertedIcon,
                                                               title: stationTo!.name,
                                                               onTap: { },
                                                               onClear: { [weak self] in self?.handleTextFieldClear(.to)} )
                self.metroMapView.fieldsState = FieldState(to: toState, from: lastState.from)
            } else {
                self.metroMapView.fieldsState = FieldState(to: self.makeInitialFieldState().to, from: lastState.from)
            }
            if stationFrom != nil && stationTo != nil {
                self.findRoute()
            }
        }
    }
    
    public var alreadyZoomedToUser = false
    private var routes = [ShortRoute]()
    private var filters = [Station.Feature]() {
        didSet {
            handleFilters()
        }
    }
    
    public var metroMapView: MetroMapView!
    
    public override func loadView() {
        super.loadView()
        view.backgroundColor = .MKBase
    }
    
    private var currentStationStack = [Station]()

    // MARK: Service
    public var metroService                : MetroService!

//    // MARK: Station
//    private var stationController          : StationController!
//    private var stationPanelController     : BasePanelController!
//
//    // MARK: ШЕЛУХА
//    private var detailEmergencyController  : DetailArticleController!
//    private var emergencyControllerFPC     : FloatingPanelController!
    private var routesControllerFPC        : BasePanelController!
//
//    // MARK: Filter
//    private var filterController           : MetroFilterController?
//
//    // MARK: Route
//    private var routeSettingsController    : RouteSettingsController?
//
    private var routesController : RoutesViewController!
    
    private var spinner = UIActivityIndicatorView(style: .gray)
    
    public enum ViewState {
        case loading
        case error
        case loaded
    }
    
    public var viewState = ViewState.loading {
        didSet {
            self.handleState(with: self.viewState)
        }
    }
    
    private func handleState(with state: ViewState) {
        switch state {
        case .loading :
            self.setupLoading()
        case .error   :
            self.spinner.isHidden = true
            self.spinner.stopAnimating()
            self.setupError()
        case . loaded :
            self.spinner.isHidden = true
            self.spinner.stopAnimating()
            self.setupLoaded()
        }
    }
}
// MARK: Common Extensions
extension MetroMapController {
    
    private func presentRouteDetailsController(_ selectedIndex: Int) {
        let routesController = RoutesViewController()
        routesController.metroService = self.metroService
        routesController.currentIndex = selectedIndex
        routesController.routes = routes
        routesController.onPageChange = { [weak self] index in
            guard let self = self else { return }
            self.handleRouteChange(index)
            if let preview = self.metroMapView.routePreview {
                preview.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .right, animated: true)
            }
        }
        let destination = BaseNavigationController(rootViewController: routesController)
        routesControllerFPC = BasePanelController(contentVC: destination, positions: .fullScreen, state: .full)
        routesControllerFPC.delegate = self
        routesControllerFPC.behavior = RoutesPanelBehavior()
        routesControllerFPC.surfaceView.grabberHandle.isHidden = true
        routesController.parentPanelController = routesControllerFPC
        destination.navigationBar.prefersLargeTitles = false
        self.present(routesControllerFPC, animated: true)
    }
    
    private func handleFilters() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            guard let stations = self.metroService?.stationsDTO else { return }
            let rawValues = self.filters.map { $0.rawValue }
            var filtered = [Int: (coordinate: MapPoint, services: [Station.Feature])]()
            for station in stations.values {
                var services = [Station.Feature]()
                for service in Array(station.services) {
                    if rawValues.contains(service) {
                        if let _service = Station.Feature(rawValue: service) {
                            services.append(_service)
                        }
                    }
                }
                if services.count != 0 {
                    filtered.updateValue((coordinate: MapPoint(x: station.x, y: station.y), services: services), forKey: station.id)
                }
            }
            DispatchQueue.main.async {
                self.metroMapView.metroMapScrollView.drawFilterMarkers(filtered)
            }
        }
    }
    
    private func setupLoading() {
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        self.spinner.color = .grey2
        self.spinner.hidesWhenStopped = true
        self.spinner.startAnimating()
        self.view.addSubview(spinner)
        self.spinner.translatesAutoresizingMaskIntoConstraints = false
        self.spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    private func setupError() {
        self.view.backgroundColor = .red
//        let errorView = ResultView(frame: .zero)
//        errorView.titleLabel.text = "Error".localized()
//        errorView.subtitleLabel.text = "Oops! Something went wrong".localized()
//        errorView.imageView.image = UIImage(named: "close_square")
//        errorView.imageView.tintColor = .metroRed
//        errorView.pin(on: self.view) {[
//            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor,    constant: 100),
//            $0.centerXAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.centerXAnchor)
//        ]}
//        let againButton = MKButton()
//        againButton.setTitleColor(.white, for: .normal)
//        againButton.setTitle("Retry again".localized(), for: .normal)
//        againButton.backgroundColor = .mainColor
//        againButton.titleLabel?.font = UIFont(name: "MoscowSans-Medium", size: 15)
//        againButton.addTarget(self, action: #selector(retryTap), for: .touchUpInside)
//        againButton.roundCorners(.all, radius: 10)
//        againButton.pin(on: self.view) {[
//            $0.heightAnchor.constraint(equalToConstant: 44),
//            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16),
//            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16),
//            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -24)
//        ]}
    }
    
    @objc
    private func retryTap() {
        self.onRetry?()
    }
    
    private func setupLoaded() {
        if self.metroMapView == nil {
            self.metroMapView = self.lazyMetroMapView()
        }
//        self.metroMapView.updateStatusBarHeight(with: Utils.getStatusBarHeight())
        self.metroMapView.alpha = 0
        self.view.addSubview(self.metroMapView)
        self.metroMapView.pin(on: self.view, {[
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 0),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 0)
        ]})
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.metroMapView.alpha = 1
        })
        guard let metroService = self.metroService else { return }
        metroService.getEmergencies { [weak self] emergencies in
            guard let self = self else { return }
            for emergency in emergencies {
                for alternative in emergency.alternativeConnections {
                    self.metroMapView.metroMapScrollView.mapOptions.connections.updateValue(GraphicsUtils.parsePath(name: "connection-\(alternative.id)", svgString: alternative.svg) as Any, forKey: "connection-\(alternative.id)")
                }
            }
            DispatchQueue.main.async {
                self.metroMapView.metroMapScrollView.drawEmergencies(emergencies)
            }
        }
        metroService.searchNearestStation(callback: { [weak self] stationID in
            guard let self = self else { return }
            guard let id = stationID else { return }
            guard let station = self.metroService?.stations.filter({ $0.id == id }).first,
                  let stationDTO = self.metroService?.get(by: id) else { return }
            let center = CGPoint(x: stationDTO.x, y: stationDTO.y)
            DispatchQueue.main.async {
                self.metroMapView.metroMapScrollView.drawUserPosition(at: center)
                if !self.alreadyZoomedToUser {
                    UIView.animate(withDuration: 0.5, delay: 0, options: [UIView.AnimationOptions.curveEaseInOut], animations: {
                        self.metroMapView.metroMapScrollView.zoom(to: CGRect(x: center.x - 300 , y: center.y - 300, width: 600, height: 600), animated: false)
                    }, completion: nil)
                    self.alreadyZoomedToUser = true
                }
                self.stationFrom = station
            }
        })
        metroService.onLocationUpdate = { [weak self] in
            guard let self = self else { return }
            metroService.searchNearestStation(callback: { [weak self] stationID in
                guard let self = self else { return }
                if self.stationFrom == nil {
                    guard let id = stationID else { return }
                    guard let station = self.metroService?.stations.filter({ $0.id == id }).first,
                          let stationDTO = self.metroService?.get(by: id) else { return }
                    let center = CGPoint(x: stationDTO.x, y: stationDTO.y)
                    DispatchQueue.main.async {
                        self.metroMapView.metroMapScrollView.drawUserPosition(at: center)
                        if !self.alreadyZoomedToUser {
                            UIView.animate(withDuration: 0.5, delay: 0, options: [UIView.AnimationOptions.curveEaseInOut], animations: {
                                self.metroMapView.metroMapScrollView.zoom(to: CGRect(x: center.x - 300 , y: center.y - 300, width: 600, height: 600), animated: false)
                            }, completion: nil)
                            self.alreadyZoomedToUser = true
                        }
                        self.stationFrom = station
                    }
                }
            })
        }
        self.spinner.stopAnimating()
        self.spinner.isHidden = true
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setTransparentNavBar()
//        AnalyticsService.reportEvent(with: "AppClip.metro")
    }
    
    private func makeBubbleState(_ selectedIndex: Int) -> BubbleState? {
        var segments = [StationBubble.ViewState.Segment]()
        for (index,station) in currentStationStack.enumerated() {
            let segment = StationBubble.ViewState.Segment(image: station.line.originalIcon,
                                                          isSelected: index == selectedIndex ? true : false,
                                                          onSelect: { [weak self] index in self?.handleBubbleSelection(index) })
            segments.append(segment)
        }
        
        guard let firstStation = currentStationStack[safe: selectedIndex] else { return nil}
        let coordinate = MapPoint(x: firstStation.mapPoint.x, y: firstStation.mapPoint.y)
        let zoomRect = CGRect(x: firstStation.mapPoint.x - 200 , y: firstStation.mapPoint.y - 200, width: 400, height: 400)
        let bubbleState = StationBubble.ViewState(coordinates: coordinate,
                                                  zoomRect: zoomRect,
                                                  segments: segments,
                                                  onButtonTap: { [weak self] index, direction in self?.handleBubbleButtonTap(selectedIndex: index, direction: direction) })
        return BubbleState.presented(bubbleState)
    }
    
    private func handleBubbleSelection(_ index: Int) {
        guard let selected = currentStationStack[safe: index] else { return }
//        self.presentStationController(with: selected)
        self.metroMapView.bubbleState = makeBubbleState(index) ?? .hidden
    }
    
    private func handleBubbleButtonTap(selectedIndex: Int, direction: Direction) {
        guard let selectedStation = self.currentStationStack[safe: selectedIndex] else { return }
        self.setStation(direction, selectedStation)
//        self.closeStationController()
    }
    
    private func makeInitialFieldState() -> FieldState {
        let fromState = StationSelectTextField.ViewState.init(color: .MKTextfield,
                                                              image: nil,
                                                              title: "From".localized(),
                                                              onTap: { },
                                                              onClear: { [weak self] in self?.handleTextFieldClear(.from)})
        
        let toState = StationSelectTextField.ViewState.init(color: .MKTextfield,
                                                            image: nil,
                                                            title: "To".localized(),
                                                            onTap: { },
                                                            onClear: { [weak self] in self?.handleTextFieldClear(.to)})
        return FieldState(to: toState, from: fromState)
    }
    
    private func lazyMetroMapView() -> MetroMapView? {
        guard let metroService = self.metroService, let options = metroService.mapDrawingOptions else { return nil }
        
        let metroMapView = MetroMapView(frame: UIScreen.main.bounds, mapDrawOptions: options)
        
        metroMapView.fieldsState = makeInitialFieldState()
        
        metroMapView.onMapTap = { [weak self] point in
            guard let self = self else { return }
            let filtered = metroService.tapGrids.filter { $0.value.contains(point)}
            if !filtered.isEmpty {
                guard let firstKey = filtered.first?.key else { return }
                self.handleMapTap(firstKey)
            } else {
                self.handleMapTap(nil)
            }
        }
        
        metroMapView.onFilterButtonTap = { [weak self] in
            guard let self = self else { return }
//            self.presentFilterController()
//            AnalyticsService.reportEvent(with: "AppClip.metro.tap.filter")
        }
        
        metroMapView.onChatButtonTap = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
//            AnalyticsService.reportEvent(with: "AppClip.metro.tap.back")
        }
        
        metroMapView.onSettingButtonTap = { [weak self] in
            guard let self = self else { return }
//            self.presentRouteSettingsController()
//            AnalyticsService.reportEvent(with: "AppClip.metro.tap.settings")
        }

        return metroMapView
    }
    
    private func handleTextFieldClear(_ direction: Direction) {
        switch direction {
        case .from:
            self.stationFrom = nil
            let lastState = self.metroMapView.fieldsState
            let initial = self.makeInitialFieldState()
            self.metroMapView.fieldsState = FieldState(to: lastState.to, from: initial.from)
        case .to:
            self.stationTo = nil
            let lastState = self.metroMapView.fieldsState
            let initial = self.makeInitialFieldState()
            self.metroMapView.fieldsState = FieldState(to: initial.to, from: lastState.from)
        }
    }
    
    private func setStation(_ direction: Direction, _ station: Station) {
        switch direction {
        case .from:
            self.stationFrom = station
        case .to:
            self.stationTo = station
        }
    }
    
    private func handleMapTap(_ stationID: Int?) {
        if let id = stationID {
            guard let service = self.metroService else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                guard let station = service.stations.filter({ $0.id == id }).first else { return }
                self.currentStationStack = [station]
                if let transitions = station.transitions {
                    transitions.forEach {
                        self.currentStationStack.append($0)
                    }
                }
                DispatchQueue.main.async {
//                    self.presentStationController(with: station)
                    if !station.emergency.isEmpty {
                        if !station.emergency.filter({ $0.status == .closed }).isEmpty {
                            self.metroMapView.bubbleState = .hidden
                        } else {
                            self.metroMapView.bubbleState = self.makeBubbleState(0) ?? .hidden
                        }
                    } else {
                        self.metroMapView.bubbleState = self.makeBubbleState(0) ?? .hidden
                    }
                }
            }
        } else {
//            self.closeStationController()
        }
    }
    
    private func findRoute() {
        routes = []
        guard let metroService = self.metroService else { return }
        guard let from = self.stationFrom, let to = self.stationTo else { return }
        let options = RoutingOptions(routeSorting: RoutingOptions.UserRouteSortingOption.init(rawValue: currentOption) ?? .classic)

        metroService.route(from: from, to: to, options: options, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let routes):
                let params: [String: Any] = [
                    "from": [
                        "id"   : from.id,
                        "line" : from.line.name,
                        "name" : from.name
                    ],
                    "to": [
                        "id"   : to.id,
                        "line" : to.line.name,
                        "name" : to.name
                    ],
                    "variants" : routes.count,
                    "totalTime": routes.map { $0.metadata.totalTime }
                ]
                DispatchQueue.main.async {
                    self.routes = routes
//                    self.closeFilterController()
//                    self.closeRouteSettingsController()
                    self.metroMapView.routeState = self.makeRouteState()
                    if let first = self.routes.first {
                        self.metroMapView.metroMapScrollView.drawRoute(first.drawMetadata)
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    SPAlert.present(title: err.errorDescription ?? "", preset: .error)
                    if err == .sameStations {
                        self.stationTo = nil
                    }
                }
            }
        })
    }
    
    private func makeRouteState() -> RouteState {
        var routesData = [RoutePreviewCollectionCell.ViewState]()
        for (index,route) in routes.enumerated() {

            let arrivalTime = String.localizedStringWithFormat("arriving in %@".localized(), Utils.getArrivalTime(route.metadata.totalTime))
            let transitionsAndCost = "\(String.localizedStringWithFormat("transfers count".localized(), route.metadata.transfers)) • \(route.metadata.cost)₽ • \(arrivalTime)"

            let state = RoutePreviewCollectionCell.ViewState(time: Utils.getTotalTime(route.metadata.totalTime),
                                                             subtitle: transitionsAndCost,
                                                             onDetailsTap: {[weak self] in
                                                                guard let self = self else { return }
                                                                self.presentRouteDetailsController(index)
                                                             },
                                                             index: index)
            routesData.append(state)
        }

        let state = MetroRoutePreview.ViewState(from: self.stationFrom?.name ?? "",
                                                to: self.stationTo?.name ?? "",
                                                onPointSelect: { [weak self] direction in
                                                    guard let self = self else { return }
//                                                    self.presentSearchController(direction)
                                                },
                                                onClose: { [weak self] in
                                                    guard let self = self else { return }
                                                    self.handleRouteClear()
                                                },
                                                onChange: { [weak self] in
                                                    guard let self = self else { return }
                                                    self.handleRouteChange()
                                                },
                                                onPageChange: { [weak self] index in
                                                    guard let self = self else { return }
                                                    self.handleRouteChange(index)
                                                },
                                                routes: routesData)
        return RouteState.presented(state)
    }
    
    private func handleRouteChange() {
        let oldFrom = stationFrom
        let oldTo = stationTo
        stationFrom = nil
        stationTo = nil
        stationFrom = oldTo
        stationTo = oldFrom
    }
    
    private func handleRouteClear() {
        self.routes = []
        self.metroMapView.routeState = .hidden
        self.stationTo = nil
    }
    
    private func handleRouteChange(_ selectedIndex: Int) {
        guard let selectedRoute = routes[safe: selectedIndex] else { return }
        self.metroMapView.metroMapScrollView.drawRoute(selectedRoute.drawMetadata)
    }
}
