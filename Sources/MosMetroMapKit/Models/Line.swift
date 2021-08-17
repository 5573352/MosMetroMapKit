//
//  Line.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 06.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import Foundation
import UIKit

struct Line {
    
    struct NeighbourLine: Hashable {
        let id: Int
        let name: String
        let color: UIColor
        let originalIcon: UIImage
        let invertedIcon: UIImage
        let firstStationID: Int
        let lastStationID: Int
        
        static func == (lhs: NeighbourLine, rhs: NeighbourLine) -> Bool {
            return lhs.id == rhs.id
        }
    }
    let id: Int
    let name: String
    let color: UIColor
    let originalIcon: UIImage
    let invertedIcon: UIImage
    let firstStationID: Int
    let lastStationID: Int
    let neigbourLines: [NeighbourLine]
}

extension Line: Hashable {
    static func == (lhs: Line, rhs: Line) -> Bool {
        return lhs.id == rhs.id
    }
    
    
}
