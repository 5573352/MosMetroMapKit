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
            title       : NSLocalizedString("Default", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
            descr       : NSLocalizedString("Routes will be sorted by transfers count and time", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
            isActivated : routeOptions.routeSorting == .classic ? true : false,
            onSelect    : { [weak self] in
                            guard let self = self else { return }
                            self.routeOptions.routeSorting = .classic
                        }
        )
        
        let minimalTimeOption = RouteSettingsView.ViewState.RouteOption(
            title       : NSLocalizedString("Only by route total time", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
            descr       : NSLocalizedString("Routes will be sorted in ascending order by time", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
            isActivated : routeOptions.routeSorting == .leastTime ? true : false,
            onSelect    : { [weak self] in
                            guard let self = self else { return }
                            self.routeOptions.routeSorting = .leastTime
                        }
        )
        
        let leastTransfersOption = RouteSettingsView.ViewState.RouteOption(
            title       : NSLocalizedString("Least transfers", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
            descr       : NSLocalizedString("Routes will be sorted in ascending order by transfers", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
            isActivated : routeOptions.routeSorting == .leastTransfers ? true : false,
            onSelect    : { [weak self] in
                            guard let self = self else { return }
                            self.routeOptions.routeSorting = .leastTransfers
                        }
        )
        
        let routeOptionsSection = Section(
            title          : NSLocalizedString("Priority", tableName: nil, bundle: .mm_Map, value: "", comment: ""),
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
        UserDefaults.standard.setValue(newRoutingOptions.routeSorting, forKey: "RouteOption")
        var text = ""
        switch self.routeOptions.routeSorting {
        case .leastTime:
            text = "TIME"
        case .classic:
            text = "DEFAULT"
        case .leastTransfers:
            text = "TRANSFERS"
        }
        self.onClose?()
    }
}
