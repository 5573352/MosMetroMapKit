//
//  TimeInterval + String.swift
//
//  Created by Сеня Римиханов on 16.04.2021.
//

import Foundation


extension TimeInterval {
    
    var positionalTime: String {
        return DateComponents.formatterPositional.string(from: self) ?? ""
    }
    
    struct DateComponents {
        
        static let formatterPositional: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute,.second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter
        }()
    }
}
