//
//  SafeIndex.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 07.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

// MARK: - Safe index in collection
public extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
