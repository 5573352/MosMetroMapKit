//
//  Line.swift
//
//  Created by Сеня Римиханов on 06.05.2020.
//

import UIKit

struct Line {
    
    let id             : Int
    let name           : String
    let color          : UIColor
    let originalIcon   : UIImage
    let invertedIcon   : UIImage
    let firstStationID : Int
    let lastStationID  : Int
    let neigbourLines  : [NeighbourLine]
    
    struct NeighbourLine: Hashable {
        let id             : Int
        let name           : String
        let color          : UIColor
        let originalIcon   : UIImage
        let invertedIcon   : UIImage
        let firstStationID : Int
        let lastStationID  : Int
        
        static func == (lhs: NeighbourLine, rhs: NeighbourLine) -> Bool {
            return lhs.id == rhs.id
        }
    }
}

extension Line : Hashable {
    
    static func == (lhs: Line, rhs: Line) -> Bool {
        return lhs.id == rhs.id
    }
}
