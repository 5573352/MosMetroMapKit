//
//  MapKit.swift
//
//  Created by Кузин Павел on 20.08.2021.
//

import UIKit

public class MapKit {
    
    static var enableSettings = true
    
    @objc
    public func closeMetro() {
        self.mapVC.dismiss(animated: true)
    }
    
    public var timeoutInSeconds : TimeInterval = 5
 
    private init() {
        // This registers the fonts
        _ = UIFont.registerFont(bundle: .mm_Map, fontName: "MoscowSans-Medium", fontExtension: "otf")
        _ = UIFont.registerFont(bundle: .mm_Map, fontName: "MoscowSans-Bold", fontExtension: "otf")
        _ = UIFont.registerFont(bundle: .mm_Map, fontName: "MoscowSans-Light", fontExtension: "otf")
        _ = UIFont.registerFont(bundle: .mm_Map, fontName: "MoscowSans-Regular", fontExtension: "otf")
        _ = UIFont.registerFont(bundle: .mm_Map, fontName: "MoscowSans-Extrabold", fontExtension: "otf")

        // This prints out all the fonts available you should notice that your custom font appears in this list
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
    }
    
    public static var shared = MapKit()
    
    
    private var mapVC = MetroMapController()
    var metroService = MetroService(isPerspective: false)
    
    public func openMetroMap(on vc: UIViewController, _ completion: (()->())? = nil) {
        self.metroService.loadAllDatabase(callback: { result in
            if result {
                DispatchQueue.main.async {
                    self.mapVC.viewState = .loading
                    self.mapVC.metroService = self.metroService
                    self.mapVC.viewState = .loaded
                    self.mapVC.modalTransitionStyle = .coverVertical
                    self.mapVC.modalPresentationStyle = .fullScreen
                    vc.present(self.mapVC, animated: true) {
                        self.mapVC.viewState = .loading
                        if self.mapVC.metroService != nil {
                            if !self.mapVC.alreadyZoomedToUser {
                                let point = CGRect(x: 1029.4000854492, y: 1153.8001098633, width: 400.0, height: 400.0)
                                self.mapVC.metroMapView.metroMapScrollView.zoom(to: point, animated: true)
                            }
                            self.mapVC.viewState = .loaded
                        }
                    }
                    completion?()
                }
            } else {
                DispatchQueue.main.async {
                    self.mapVC.viewState = .error
                }
            }
        })
    }
    
    public func createRoute(_ stationA: String = "Измайловская", _ stationB: String = "Красносельская") {
        DispatchQueue.main.async {
            guard self.metroService.stations.isEmpty == false else {
                self.createRoute(stationA, stationB)
                return
            }
            let A : Station? = self.metroService.stations.filter {
                print($0.name)
                return $0.name == stationA
            }.first
            let B : Station? = self.metroService.stations.filter {
                return $0.name == stationB
            }.first
            self.mapVC.stationFrom = A
            self.mapVC.stationTo = B
        }
    }
}

extension UIFont {
    
    static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) -> Bool {

        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
            fatalError("Couldn't find font \(fontName)")
        }

        guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
            fatalError("Couldn't load data from the font \(fontName)")
        }

        guard let font = CGFont(fontDataProvider) else {
            fatalError("Couldn't create font from data")
        }

        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterGraphicsFont(font, &error)
        guard success else {
            print("Error registering font: maybe it was already registered.")
            return false
        }
        return true
    }
}
