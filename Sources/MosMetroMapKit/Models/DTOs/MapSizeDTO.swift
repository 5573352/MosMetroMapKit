//
//  MapSizeDTO.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 12.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import Foundation

class MapSizeDTO {
    var id: Int = 1
    var width: Double = 0.0
    var height: Double = 0.0
    
    // MARK: Primary key
    static func primaryKey() -> String? {
        return "id"
    }
}
