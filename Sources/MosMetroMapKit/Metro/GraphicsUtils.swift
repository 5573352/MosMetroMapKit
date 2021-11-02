//
//  GraphicsUtils.swift
//  PackageTester
//
//  Created by Кузин Павел on 17.08.2021.
//

import UIKit

class GraphicsUtils {
    
    static func parseGradient(_ name: String, _ value: String, _ gradientValue: String) -> GradientDrawingData? {
        if let maskElement = try? SVGParser.parse(text: "<svg>\(gradientValue)\(value)</svg>"), let rect = maskElement.bounds?.toCG() {
            let image = maskElement.toNativeImage(size: Size(Double(rect.width * UIScreen.main.scale), Double(rect.height * UIScreen.main.scale)))
            guard let cgImage = image.cgImage else { return nil}
            return GradientDrawingData(cgImage: cgImage, frame: rect)
        }
        return nil
    }
    
    static func parseAdditional(_ json: JSON) -> [String: AdditionalDrawindData] {
        var result = [String: AdditionalDrawindData]()
        for (key,value) in json {
            if let element = try? SVGParser.parse(text: "<svg>\(value)</svg>"), let rect = element.bounds?.toCG() {
                let image = element.toNativeImage(size: Size(Double(rect.width * UIScreen.main.scale), Double(rect.height * UIScreen.main.scale)))
                guard let cgImage = image.cgImage else { continue }
                result.updateValue(AdditionalDrawindData(cgImage: cgImage, frame: rect), forKey: key)
            }
        }
        return result
    }
    
    static func parseSingleAddtional(_ svgString: String) -> AdditionalDrawindData? {
        if let element = try? SVGParser.parse(text: "<svg>\(svgString)</svg>"), let rect = element.bounds?.toCG() {
            let image = element.toNativeImage(size: Size(Double(rect.width * UIScreen.main.scale), Double(rect.height * UIScreen.main.scale)))
            guard let cgImage = image.cgImage else { return nil }
            return AdditionalDrawindData(cgImage: cgImage, frame: rect)
        }
        return nil
    }
    
    static func parsePath(name: String, svgString: String) -> Any? {
        // Single element
        if let parsedElement = try? SVGParser.parse(text: "<svg>\(svgString)</svg>"),
           let group = parsedElement as? Group,
           let shape = group.contents[safe: 0] as? Shape {
            return parse(name: name, shape: shape)
        }
        
        if let parsedElement = try? SVGParser.parse(text: "<svg>\(svgString)</svg>"),
           let group = parsedElement as? Group,
           let innerGroup = group.contents[safe: 0] as? Group {
            var shapes = [ShapeDrawingData]()
            for node in innerGroup.contents {
                if let shape = node as? Shape {
                    shapes.append(parse(name: name, shape: shape))
                }
            }
            return ShapesGroup(shapes: shapes)
        }
        return nil
    }
    
    static private func parse(name: String, shape: Shape) -> ShapeDrawingData {
        var shapeData = ShapeDrawingData(path: shape.form.toCGPath(), name: name, fillColor: nil, strokeColor: nil, strokeWidth: nil, transform: shape.place.toCG())
        
        if let color = shape.fill as? Color {
            shapeData.fillColor = UIColor(cgColor: color.toCG())
        }
        
        if let stroke = shape.stroke, let color = stroke.fill as? Color {
            shapeData.strokeColor = UIColor.init(cgColor: color.toCG())
            shapeData.strokeWidth = CGFloat(stroke.width)
            shapeData.fillColor = nil
        }
        return shapeData
    }
}

