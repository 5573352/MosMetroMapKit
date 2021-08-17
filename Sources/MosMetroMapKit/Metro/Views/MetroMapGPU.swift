////
////  MetroMapGPU.swift
////  MosmetroNew
////
////  Created by Сеня Римиханов on 04.05.2020.
////  Copyright © 2020 Гусейн Римиханов. All rights reserved.
////
//
import UIKit


class UIOutlinedLabel: UILabel {

    var outlineWidth: CGFloat = 2
    var outlineColor: UIColor = .MKBase
    
    override func drawText(in rect: CGRect) {
        let shadowOffset = self.shadowOffset
        let textColor = self.textColor
        
        let c = UIGraphicsGetCurrentContext()
        c?.setLineWidth(outlineWidth)
        c?.setLineJoin(.round)
        c?.setTextDrawingMode(.stroke)
        self.textColor = outlineColor;
        super.drawText(in:rect)
        
        c?.setTextDrawingMode(.fill)
        self.textColor = textColor
        self.shadowOffset = CGSize(width: 0, height: 0)
        super.drawText(in:rect)
        
        self.shadowOffset = shadowOffset
    }
}

extension NSAttributedString {
    func cgPath() -> CGMutablePath {
        let textPath = CGMutablePath()
        let line = CTLineCreateWithAttributedString(self)

        let runs = CTLineGetGlyphRuns(line) as! [CTRun]

        for run in runs
        {
            let attributes: NSDictionary = CTRunGetAttributes(run)
            let font = attributes[kCTFontAttributeName as String] as! CTFont

            let count = CTRunGetGlyphCount(run)

            for index in 0 ..< count
            {
                let range = CFRangeMake(index, 1)

                var glyph = CGGlyph()
                CTRunGetGlyphs(run, range, &glyph)

                var position = CGPoint()
                CTRunGetPositions(run, range, &position)

                let letterPath = CTFontCreatePathForGlyph(font, glyph, nil)
                let transform = CGAffineTransform(translationX: position.x, y: position.y)

                textPath.addPath(letterPath!, transform: transform)
            }
        }
        return textPath
    }
}

extension UIBezierPath {

    convenience init(text: NSAttributedString) {
        let textPath = CGMutablePath()
        let line = CTLineCreateWithAttributedString(text)

        let runs = CTLineGetGlyphRuns(line) as! [CTRun]

        for run in runs
        {
            let attributes: NSDictionary = CTRunGetAttributes(run)
            let font = attributes[kCTFontAttributeName as String] as! CTFont

            let count = CTRunGetGlyphCount(run)

            for index in 0 ..< count
            {
                let range = CFRangeMake(index, 1)

                var glyph = CGGlyph()
                CTRunGetGlyphs(run, range, &glyph)

                var position = CGPoint()
                CTRunGetPositions(run, range, &position)

                let letterPath = CTFontCreatePathForGlyph(font, glyph, nil)
                let transform = CGAffineTransform(translationX: position.x, y: position.y)

                textPath.addPath(letterPath!, transform: transform)
            }
        }

        self.init(cgPath: textPath)
    }
}

public class MapViewLayered: UIView {
    
    
    var captions    = [String: TextDrawingData]()
    var connections = [String: Any]()
    var stations    = [String: Any]()
    var transitions = [String: Any]()
    var additional  = [AdditionalDrawindData]()
    var shouldDraw  = true
    var fromCoordinate : MapPoint?
    var toCoordinate   : MapPoint?
    
    struct ViewState {
        let captionsData: [TextDrawingData]
        
        struct TextDrawingData {
            let frame: CGRect
            let text: String
            let transform: CGAffineTransform
            let name: String
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        redrawAfterTraitChange()
    }
    
    func redrawAfterTraitChange() {
        self.layer.sublayers?.forEach {
            guard let metroLayer = $0 as? MetroShapeLayer else { return }
            if metroLayer.isNeedToRedraw {
                metroLayer.fillColor = UIColor.MKBase.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.layer.drawsAsynchronously = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
    }
    
    public override func removeFromSuperview() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }, completion: { (finished: Bool) in
            if finished {
               super.removeFromSuperview()
            }
        })
    }
    
    public func redraw() {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.shouldDraw = true
    }
    
    public override func draw(_ layer: CALayer, in ctx: CGContext) {
        if shouldDraw {
            connections.forEach {
                if let shapeData = $0.value as? ShapeDrawingData {
                    self.layer.addSublayer(drawShape(shapeData))
                }
                
                if let groupData = $0.value as? ShapesGroup {
                    let shapeContainer = CAShapeLayer()
                    shapeContainer.name = $0.key
                    shapeContainer.minificationFilter = .nearest
                    shapeContainer.magnificationFilter = .nearest
                    groupData.shapes.forEach { shapeContainer.addSublayer(drawShape($0)) }
                    self.layer.addSublayer(shapeContainer)
                }
            }
            
            stations.forEach {
                if let shapeData = $0.value as? ShapeDrawingData {
                    self.layer.addSublayer(drawShape(shapeData))
                }
                
                if let groupData = $0.value as? ShapesGroup {
                    let shapeContainer = CAShapeLayer()
                    shapeContainer.name = $0.key
                    shapeContainer.minificationFilter = .nearest
                    shapeContainer.magnificationFilter = .nearest
                    groupData.shapes.forEach { shapeContainer.addSublayer(drawShape($0)) }
                    self.layer.addSublayer(shapeContainer)
                }
            }
            
            transitions.forEach {
                if let shapeData = $0.value as? ShapeDrawingData {
                    self.layer.addSublayer(drawShape(shapeData))
                }
                
                if let groupData = $0.value as? ShapesGroup {
                    let shapeContainer = CAShapeLayer()
                    shapeContainer.name = $0.key
                    shapeContainer.minificationFilter = .nearest
                    shapeContainer.magnificationFilter = .nearest
                    groupData.shapes.forEach { shapeContainer.addSublayer(drawShape($0)) }
                    self.layer.addSublayer(shapeContainer)
                }
                
                if let gradientImage = $0.value as? GradientDrawingData {
                    drawGradient(gradientImage)
                }
                
            }
            
            additional.forEach { self.drawAddtional($0) }
            
            captions.forEach {
                drawText($0.value)
            }
            
            if let fromCoordinate = self.fromCoordinate, let toCoordinate = self.toCoordinate {
                let fromImageBubble = #imageLiteral(resourceName: "from_bubble")
                let toImageBubble = #imageLiteral(resourceName: "to_bubble")
                let fromImageLayer = CALayer()
                fromImageLayer.frame = CGRect(x: fromCoordinate.x-25, y: fromCoordinate.y-45, width: 50, height: 50 * 1.12)
                fromImageLayer.contents = fromImageBubble.cgImage
                fromImageLayer.contentsGravity = .resizeAspect
                fromImageLayer.contentsScale = UIScreen.main.scale+1
                
                let toImageLayer = CALayer()
                toImageLayer.frame = CGRect(x: toCoordinate.x-25, y: toCoordinate.y-45, width: 50, height: 50 * 1.12)
                toImageLayer.contents = toImageBubble.cgImage
                toImageLayer.contentsGravity = .resizeAspect
                toImageLayer.contentsScale = UIScreen.main.scale+1
                self.layer.addSublayer(fromImageLayer)
                self.layer.addSublayer(toImageLayer)
            }
           
            self.shouldDraw = false
        } else { }
    }
    
    public func drawGradient(_ gradientData: GradientDrawingData) {
        let layer = CALayer()
        layer.frame = gradientData.frame
        layer.contents = gradientData.cgImage
        layer.contentsGravity = .resizeAspect
        layer.contentsScale = UIScreen.main.scale+1
        self.layer.addSublayer(layer)
    }
    
    public func drawAddtional(_ gradientData: AdditionalDrawindData) {
           let layer = CALayer()
           layer.frame = gradientData.frame
           layer.contents = gradientData.cgImage
        layer.contentsGravity = .resizeAspect
           layer.contentsScale = UIScreen.main.scale + 1
           self.layer.addSublayer(layer)
       }
    
    public func drawText(_ textData: TextDrawingData) {
        var frame = textData.frame
        frame.origin.y += 4
        frame.size.width += 10
        let stationLabel = UIOutlinedLabel(frame: frame)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 0.2

        let hyphenAttribute = [
            NSAttributedString.Key.paragraphStyle : paragraphStyle,
            ] as [NSAttributedString.Key : Any]

        let attributedString = NSMutableAttributedString(string: textData.text, attributes: hyphenAttribute)
        
        stationLabel.attributedText = attributedString
        stationLabel.textColor = .textPrimary
        stationLabel.font = UIFont.MAP_TEXT
        stationLabel.numberOfLines = 0
        stationLabel.sizeToFit()
        
        self.addSubview(stationLabel)
        //                stationLabel.layer.minificationFilter = .nearest
        //                stationLabel.layer.magnificationFilter = .nearest
        
        //self.layer.addSublayer(stationLabel.layer)
        
    }
    
    public func layer(by id: String) -> CALayer? {
        if let sublayers = self.layer.sublayers {
            let filtered = sublayers.filter { $0.name == id }
            if !filtered.isEmpty {
                return filtered.first!
            } else {
                return nil
            }
        }
        return nil
    }
    
    public func drawShape(_ shapeData: ShapeDrawingData) -> CALayer {
        let shape = MetroShapeLayer()
        shape.path = shapeData.path
        shape.setAffineTransform(shapeData.transform)
        shape.name = shapeData.name
        if shapeData.fillColor == nil {
            if #available(iOS 13.0, *) {
                shape.fillColor = Constants.isDarkModeEnabled ? UIColor.MKBase.resolvedColor(with: UITraitCollection.init(userInterfaceStyle: .dark)).cgColor : UIColor.MKBase.resolvedColor(with: UITraitCollection.init(userInterfaceStyle: .light)).cgColor
            } else {
                shape.fillColor = UIColor.MKBase.cgColor
            }
            shape.isNeedToRedraw = true
            if let strokeColor = shapeData.strokeColor, let strokeWidth = shapeData.strokeWidth {
                shape.strokeColor = strokeColor.cgColor
                shape.lineWidth = strokeWidth
            }
        } else {
            shape.fillColor = shapeData.fillColor!.cgColor
        }
        shape.minificationFilter = .nearest
        shape.magnificationFilter = .nearest
        return shape
    }
}
