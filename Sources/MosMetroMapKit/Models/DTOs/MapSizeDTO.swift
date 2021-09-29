//
//  MapSizeDTO.swift
//
//  Created by Павел Кузин on 12.04.2021.
//

import Foundation

class MapSizeDTO {
    var id     : Int    = 1
    var width  : Double = 0.0
    var height : Double = 0.0
    
    static func primaryKey() -> String? {
        return "id"
    }
}
