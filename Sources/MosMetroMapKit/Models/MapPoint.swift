//
//  MapPoint.swift
//
//  Created by Кузин Павел on 17.08.2021.
//

import Foundation

public struct MapPoint : Hashable {
    
    let x : Double
    let y : Double
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    init(latitude: Double, longitude: Double) {
        self.x = latitude
        self.y = longitude
    }
    
    func heading(to: MapPoint) -> Double {
        let lat1 = self.x.degreesToRadians
        let lon1 = self.y.degreesToRadians

        let lat2 = to.x.degreesToRadians
        let lon2 = to.y.degreesToRadians
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        let headingDegrees = atan2(y, x).radiansToDegrees
        if headingDegrees >= 0 {
            return headingDegrees
        } else {
            return headingDegrees + 360
        }
    }
}

extension Double {

    var degreesToRadians : Self { return self * .pi / 180 }
    var radiansToDegrees : Self { return self * 180 / .pi }
}
