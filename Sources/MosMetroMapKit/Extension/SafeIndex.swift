//
//  SafeIndex.swift
//
//  Created by Павел Кузин on 07.12.2020.
//

import UIKit

public extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
