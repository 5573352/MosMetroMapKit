//
//  RouteOptionsDTO.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 20.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
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
    
    // MARK: Primary key
    static func primaryKey() -> String? {
        return "id"
    }
}
