//
//  Extensions.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 04.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit
import CoreGraphics

// MARK: CALayer and redraw
class MetroLayer: CALayer {
    var isNeedToRedraw = false
}

class MetroShapeLayer: CAShapeLayer {
    var isNeedToRedraw = false
}
