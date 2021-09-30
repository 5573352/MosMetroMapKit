//
//  GraphicsModels.swift
//
//  Created by Сеня Римиханов on 27.05.2020.
//

import UIKit

public struct ShapesGroup {
    var shapes : [ShapeDrawingData]
}

public struct GradientDrawingData {
    let cgImage : CGImage
    let frame   : CGRect
}

public struct ShapeDrawingData {
    var path        : CGPath
    let name        : String
    var fillColor   : UIColor?
    var strokeColor : UIColor?
    var strokeWidth : CGFloat?
    var transform   : CGAffineTransform
}

public struct AdditionalDrawindData {
    let cgImage : CGImage
    let frame   : CGRect
}

public struct TextDrawingData {
    let frame : CGRect
    let text  : String
}

public struct MapDrawingOptions {
    var stations    : [String: Any]
    var connections : [String: Any]
    var transitions : [String: Any]
    var captions    : [String: TextDrawingData]
    var mapSize     : CGSize
    var addtional   : [AdditionalDrawindData]
}
