//
//  MetroFilterController.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 23.08.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit
import FloatingPanel

class MetroFilterController : BasePanController {
    
    var combine        = [String]()
    var onClose        : (()->())?
    var onClearSelect  : (()->())?
    var onSubmitSelect : (([Station.Feature]) -> Void)?
    
    var featuresDict : [String : Bool] = ["": false]

    var settedFilters = [Station.Feature]() {
        didSet {
            setState()
        }
    }
    
    let metroFilterView = MetroFilterView(frame: UIScreen.main.bounds)
    
    override func loadView() {
        super.loadView()
        view = metroFilterView
        metroFilterView.onClose = { [weak self] in
            guard let self = self else { return }
            self.onClose?()
        }
        metroFilterView.buttonsState = MetroFilterView.ButtonsState(
            mainButtonTitle      : "Apply".localized(),
            secondaryButtonTitle : "Clear".localized(),
            onButtonTap          : { [weak self] button in
                guard let self = self else { return }
                self.handleButtonTap(button, self)
        })
    }
    
    private func handleButtonTap(_ button: ButtonType, _ self: MetroFilterController) {
        switch button {
        case .main:
            self.onSubmitSelect?(self.settedFilters)
            #if MAIN_APP || APPCLIP
            AnalyticsService.reportEvent(with: "newmetro.views.metro.filterFeatures", parameters: self.featuresDict)
            #endif
            for (key, value) in self.featuresDict where value == true {
                self.combine.append(key)
            }
            #if MAIN_APP || APPCLIP
            AnalyticsService.reportEvent(with: "newmetro.metro.combineFeatures", parameters: ["features" : self.combine])
            #endif
        case .secondary:
            #if MAIN_APP || APPCLIP
            AnalyticsService.reportEvent(with: "newmetro.metro.tap.resetFilter")
            #endif
            self.settedFilters.removeAll()
            self.onClearSelect?()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if MAIN_APP || APPCLIP
        AnalyticsService.reportEvent(with: "newmetro.views.metro.filter")
        #endif
    }
}

extension MetroFilterController {
    
    private func setState() {
        let discalaimerRow = MetroFilterView.ViewState.Disclaimer(
            title          : "Find station by filters".localized(),
            detailText     : "Select one or several filters to find matching station".localized()
        )
        let disclaimerSection = Section(
            title          : "",
            isNeedToExpand : false,
            isExpanded     : true,
            rows           : [discalaimerRow],
            onExpandTap    : nil
        )
        let featuresRows: [MetroFilterView.ViewState.FilterOption] = Station.Feature.allCases.compactMap { [weak self] feature in
            guard let self = self else { return nil }
            featuresDict[feature.stationDesc] = self.checkSetted(feature: feature)
            
            return MetroFilterView.ViewState.FilterOption(
                title      : feature.stationDesc,
                icon       : feature.image,
                onSelect   : { [weak self] in
                    guard let self = self else { return }
                    self.handleFilterSelection(with: feature)
                },
                isSelected : self.checkSetted(feature: feature)
            )
        }
        let featuresSection = Section(
            title          : "",
            isNeedToExpand : false,
            isExpanded     : true,
            rows           : featuresRows,
            onExpandTap    : nil
        )
        
        metroFilterView.viewState = MetroFilterView.ViewState(
            sections: [disclaimerSection,featuresSection]
        )
    }
    
    private func checkSetted(feature: Station.Feature) -> Bool {
        if self.settedFilters.contains(feature) { return true }
        return false
    }
    
    private func handleFilterSelection(with feature: Station.Feature) {
        if self.settedFilters.contains(feature) {
            guard let index = self.settedFilters.firstIndex(of: feature) else { return }
            self.settedFilters.remove(at: index)
        } else {
            self.settedFilters.append(feature)
        }
    }
}
