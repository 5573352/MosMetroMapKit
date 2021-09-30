//
//  RoughtOptions.swift
//
//  Created by Павел Кузин on 12.04.2021.
//

import Foundation

struct RoutingOptions {
    
    var routeSorting: UserRouteSortingOption
    
    enum UserRouteSortingOption : Int {
        case classic = 1
        case leastTime = 0
        case leastTransfers = 2
    }
}
