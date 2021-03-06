//
//  RouteOptionsDTO.swift
//
//  Created by Павел Кузин on 20.04.2021.
//

import Foundation

class RoutingOptionsDTO {
    /// possible enums
    /// 0 – least time
    /// 1– classic (least time & least transfers combined)
    /// 2 - least transfers
    
    var id = 1
    var routeSorting = 1
    var isMCDdisabled = false
    var isMCCdisabled = false
    
    static func primaryKey() -> String? {
        return "id"
    }
}
