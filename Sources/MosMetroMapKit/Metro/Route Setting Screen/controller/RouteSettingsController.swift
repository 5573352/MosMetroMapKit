//
//  RouteSettingsController.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 06.09.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class RouteSettingsController: BasePanController {
    
    public var onClose  : (()->())?
    
    let settingsView = RouteSettingsView(frame: UIScreen.main.bounds)
    
    #if MAIN_APP
    let realmContext = RealmStorageContext(.bookmarkConfiguration)
    #endif
    
    var routeOptions: RoutingOptions! {
        didSet {
            settingsView.viewState = makeState()
        }
    }
    
    override func loadView() {
        super.loadView()
        view = settingsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        #if MAIN_APP
        guard let optionsDTO = realmContext.fetch(RoutingOptionsDTO.self, primaryKey: 1) else { return }
        self.routeOptions = RoutingOptions(routeSorting: RoutingOptions.UserRouteSortingOption(rawValue: optionsDTO.routeSorting) ?? .classic)
        #else
        self.routeOptions = RoutingOptions(routeSorting: RoutingOptions.UserRouteSortingOption(rawValue: UserDefaults.standard.integer(forKey: "RouteOption")) ?? .classic)
        #endif
    }
}

extension RouteSettingsController {
    
    private func makeState() -> RouteSettingsView.ViewState {
        let classisOption = RouteSettingsView.ViewState.RouteOption(
            title       : "Default".localized(),
            descr       : "Routes will be sorted by transfers count and time".localized(),
            isActivated : routeOptions.routeSorting == .classic ? true : false,
            onSelect    : { [weak self] in
                            guard let self = self else { return }
                            self.routeOptions.routeSorting = .classic
                        }
        )
        
        let minimalTimeOption = RouteSettingsView.ViewState.RouteOption(
            title       : "Only by route total time".localized(),
            descr       : "Routes will be sorted in ascending order by time".localized(),
            isActivated : routeOptions.routeSorting == .leastTime ? true : false,
            onSelect    : { [weak self] in
                            guard let self = self else { return }
                            self.routeOptions.routeSorting = .leastTime
                        }
        )
        
        let leastTransfersOption = RouteSettingsView.ViewState.RouteOption(
            title       : "Least transfers".localized(),
            descr       : "Routes will be sorted in ascending order by transfers".localized(),
            isActivated : routeOptions.routeSorting == .leastTransfers ? true : false,
            onSelect    : { [weak self] in
                            guard let self = self else { return }
                            self.routeOptions.routeSorting = .leastTransfers
                        }
        )
        
        let routeOptionsSection = Section(
            title          : "Priority".localized(),
            isNeedToExpand : false,
            isExpanded     : true,
            rows           : [classisOption,minimalTimeOption,leastTransfersOption],
            onExpandTap    : nil
        )
        
        return RouteSettingsView.ViewState(
            sections : [routeOptionsSection],
            onClose  : { [weak self] in
                guard let self = self else { return }
                self.onClose?()
            },
            onSave   : { [weak self] in
                guard let self = self else { return }
                self.saveSettings()
            }
        )
    }
    
    private func saveSettings() {
        let newRoutingOptions = RoutingOptionsDTO()
        newRoutingOptions.id = 1
        newRoutingOptions.routeSorting = self.routeOptions.routeSorting.rawValue
        #if MAIN_APP
        realmContext.commitWrite { [weak self] in
            guard let self = self else { return }
            self.realmContext.save2(newRoutingOptions, 1)
        }
        #else
        UserDefaults.standard.setValue(newRoutingOptions.routeSorting, forKey: "RouteOption")
        #endif
        
        var text = ""
        switch self.routeOptions.routeSorting {
        case .leastTime:
            text = "TIME"
        case .classic:
            text = "DEFAULT"
        case .leastTransfers:
            text = "TRANSFERS"
        }
        #if MAIN_APP || APPCLIP
        let params = ["option": text]
        AnalyticsService.reportEvent(with: "newmetro.metro.selectedRouteOption", parameters: params)
        #endif
        self.onClose?()
    }
}
