import UIKit

struct MosMetroMapKit {
    
}

public class MapKit {
 
    private init() {}
    public static var shared = MapKit()
    
    
    private var mapVC = MetroMapController()
    public var metroService = MetroService(isPerspective: false)
    
    public func openMetroMap(on vc: UIViewController, _ completion: (()->())? = nil) {
        self.metroService.loadAllDatabase(callback: { result in
            if result {
                DispatchQueue.main.async {
                    self.mapVC.viewState = .loading
                    self.mapVC.metroService = self.metroService
                    self.mapVC.viewState = .loaded
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
    
    public func createRoute(_ stationA: String = "Говорово", _ stationB: String = "Тверская") {
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
