//
//  FloatingPanel+Extentions.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 08.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit
import FloatingPanel

extension FloatingPanelController {
    
    static func metroAppereance() -> SurfaceAppearance {
        let appearance = SurfaceAppearance()
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        appearance.shadows = [shadow]
        appearance.cornerRadius = 16.0
        appearance.backgroundColor = .clear
        return appearance
    }
    
    static func metroAppereanceNew() -> SurfaceAppearance {
        let appearance = SurfaceAppearance()
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        appearance.shadows = [shadow]
        appearance.cornerRadius = 16.0
        appearance.backgroundColor = .MKBase
        return appearance
    }
}
