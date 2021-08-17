//
//  RoughtOptions.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 12.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import Foundation

public struct RoutingOptions {
    
    enum UserRouteSortingOption: Int {
        case leastTime = 0
        case classic = 1
        case leastTransfers = 2
    }
    
    var routeSorting: UserRouteSortingOption
}
