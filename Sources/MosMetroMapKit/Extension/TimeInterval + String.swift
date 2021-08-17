//
//  TimeInterval + String.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 16.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import Foundation


extension TimeInterval {
    struct DateComponents {
        static let formatterPositional: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute,.second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter
        }()
    }
    var positionalTime: String {
        return DateComponents.formatterPositional.string(from: self) ?? ""
    }
}
