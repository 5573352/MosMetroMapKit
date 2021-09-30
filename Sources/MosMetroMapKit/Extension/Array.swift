//
//  Array.swift
//
//  Created by Павел Кузин on 17.12.2020.
//

import UIKit

extension Array where Element: Equatable {
    
    mutating func uniquelyAppend(_ element: Element) {
        if !self.contains(element) {
            self.append(element)
        }
    }
}

public extension Array where Element: Hashable {
    
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}
