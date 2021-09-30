//
//  MetroMapScrollView.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 04.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol MetroMapScrollViewDelegate : AnyObject {
    func onSingleTap(_ scrollView: MetroMapScrollView, point: CGPoint)
}

class MetroMapScrollView : UIScrollView {
    
    public var mapView: MapViewLayered!
    public weak var metroScrollDelegate: MetroMapScrollViewDelegate?
    public var stationBubble: StationBubble!
    private var userLocationImageView: UIImageView!
    public var mapOptions: MapDrawingOptions!
    
    convenience init(with options: MapDrawingOptions) {
        self.init()
        mapOptions = options
        setup()
        DispatchQueue.main.asyncAfter(deadline: .now() , execute: { [weak self] in
            guard let self = self else { return }
            self.zoom(to: CGRect(x: self.contentSize.width / 2 - 300, y: self.contentSize.height / 2 - 300, width: 600, height: 600), animated: false)
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        typeOut("SCALE - \(scrollView.zoomScale)")
        typeOut("OFFSET - \(scrollView.contentOffset)")
        if userLocationImageView != nil {
            self.userLocationImageView.transform = CGAffineTransform(scaleX: 1.0/scrollView.zoomScale, y: 1.0/scrollView.zoomScale)
        }
    }
}

extension MetroMapScrollView {
    
    public func drawUserPosition(at point: CGPoint) {
        if self.userLocationImageView != nil {
            self.userLocationImageView.frame = CGRect(x: point.x-30.5, y: point.y-30.5, width: 61.0, height: 61.0)
            self.userLocationImageView.transform = CGAffineTransform(scaleX: 1.0/self.zoomScale, y: 1.0/self.zoomScale)
        } else {
            self.userLocationImageView = UIImageView(frame: CGRect(x: point.x-30.5, y: point.y-30.5, width: 61.0, height: 61.0))
            self.userLocationImageView.transform = CGAffineTransform(scaleX: 1.0/self.zoomScale, y: 1.0/self.zoomScale)
            self.userLocationImageView.tag = 10
            self.userLocationImageView.backgroundColor = UIColor.clear
            self.userLocationImageView.image = #imageLiteral(resourceName: "Location")
           mapView.addSubview(userLocationImageView)
        }
    }
    
    public func removeFilterMarkers() {
        let markers = self.mapView.subviews.filter { $0 is MarkerView || $0 is MarkerLabelView }
        markers.forEach { $0.removeFromSuperview() }
    }
    
    public func drawFilterMarkers(_ data: [Int: (coordinate: MapPoint, services: [Station.Feature])]) {
        self.removeFilterMarkers()
        for item in data {
            let frame = CGRect(x: item.value.coordinate.x-8, y: item.value.coordinate.y-8, width: 16, height: 16)
            if item.value.services.count > 1 {
                let markerView = MarkerLabelView.loadFromNib()
                markerView.countLabel.text = "\(item.value.services.count)+"
                markerView.frame = frame
                self.mapView.addSubview(markerView)
            } else {
                let markerView = MarkerView.loadFromNib()
                markerView.iconImageView.image = item.value.services[0].image
                markerView.frame = frame
                self.mapView.addSubview(markerView)
            }
        }
    }
    
    private func addEmergency(stationPath: CALayer, path: CGPath, image: CGImage?) {
        let layer = CALayer()
        var rect = path.boundingBox
        rect.size = CGSize(width: rect.width + 4, height: rect.height + 4)
        rect.origin.x -= 2
        rect.origin.y -= 2
        layer.frame = rect
        layer.contents = image
        layer.contentsGravity = .resizeAspect
        layer.contentsScale = UIScreen.main.scale + 1
        self.mapView.layer.addSublayer(layer)
        stationPath.removeFromSuperlayer()
    }
    
    private func handleAlternative(_ emergency: Emergency) {
        for conn in emergency.alternativeConnections {
            if let element = self.mapOptions.connections["connection-\(conn.id)"] {
                if let shapeData = element as? ShapeDrawingData {
                    self.mapView.layer.insertSublayer(self.mapView.drawShape(shapeData),at: 0)
                }
                if let groupData = element as? ShapesGroup {
                    let shapeContainer = CAShapeLayer()
                    shapeContainer.name = "connection-\(conn.id)"
                    shapeContainer.minificationFilter = .nearest
                    shapeContainer.magnificationFilter = .nearest
                    groupData.shapes.forEach { shapeContainer.addSublayer(self.mapView.drawShape($0)) }
                    self.mapView.layer.insertSublayer(shapeContainer, at: 0)
                }
            }
        }
        
        for trans in emergency.alternativeTransitions {
            if let element = self.mapOptions.transitions["transition-\(trans.id)"] {
                if let gradientImage = element as? GradientDrawingData {
                    self.mapView.drawGradient(gradientImage)
                }
            }
        }
        
        for station in emergency.alternativeStations {
            if let element = self.mapOptions.stations["station-\(station.id)"] {
                if let shapeData = element as? ShapeDrawingData {
                    self.mapView.layer.addSublayer(self.mapView.drawShape(shapeData))
                }
                if let groupData = element as? ShapesGroup {
                    let shapeContainer = CAShapeLayer()
                    shapeContainer.name = "station-\(station.id)"
                    shapeContainer.minificationFilter = .nearest
                    shapeContainer.magnificationFilter = .nearest
                    groupData.shapes.forEach { shapeContainer.addSublayer(self.mapView.drawShape($0)) }
                    self.mapView.layer.addSublayer(shapeContainer)
                }
            }
        }
    }
    
    public func drawEmergencies(_ emergencies: [Emergency]) {
        for emergency in emergencies {
            for station in emergency.stations {
                guard let sublayers = mapView.layer.sublayers,
                let stationPath =  sublayers.filter({ $0.name ==  "station-\(station.id)" }).first as? CAShapeLayer else { continue }
                if let path = stationPath.path {
                    if station.status != .info {
                        let image = imageForEmergency(station.status).cgImage
                        self.addEmergency(stationPath: stationPath, path: path, image: image)
                    }
                } else {
                    if let sublayers = stationPath.sublayers {
                        if !sublayers.isEmpty {
                            let combinedPath = CGMutablePath()
                            sublayers.forEach {
                                if let shapeLayer = $0 as? CAShapeLayer, let path = shapeLayer.path {
                                    combinedPath.addPath(path)
                                }
                            }
                            let image = imageForEmergency(station.status).cgImage
                            self.addEmergency(stationPath: stationPath, path: combinedPath, image: image)
                        }
                    }
                }
            }
            
            if let extraDrawings = emergency.extraSVG {
                let layer = CALayer()
                layer.frame = extraDrawings.frame
                layer.contents = extraDrawings.cgImage
                layer.contentsGravity = .resizeAspect
                layer.contentsScale = UIScreen.main.scale + 1
                self.mapView.layer.insertSublayer(layer, at: 0)
            }
            
            let connectionsRedraw = emergency.connections.filter { $0.redraw }.map { "connection-\($0.id)" }
            let connectionsRedraw1 = emergency.connections.filter { $0.redraw }.map { "connection-\($0.id+1000)" }
            let merged = connectionsRedraw + connectionsRedraw1
            let sublayers = mapView.layer.sublayers
            let connections = sublayers?.filter { merged.contains($0.name ?? "") }
            
            if let conns = connections {
                for conn in conns {
                    if connectionsRedraw.contains(conn.name ?? "") {
                        if let shape = conn as? CAShapeLayer {
                            shape.strokeColor = UIColor.mm_TextSecondary.cgColor
                            shape.fillColor = UIColor.clear.cgColor
                            shape.lineWidth = 1
                            shape.lineDashPattern = [0.5,2]
                            shape.lineCap = .round
                        }
                    } else {
                        conn.removeFromSuperlayer()
                    }
                }
            }
            
            self.handleAlternative(emergency)
        }
    }
    
    public func drawBubble(_ coordinate: MapPoint, isFrom: Bool) {
        let image = isFrom ? #imageLiteral(resourceName: "from_bubble") : #imageLiteral(resourceName: "to_bubble")
        let bubble = UIImageView(image: image)
        bubble.tag = isFrom ? 998 : 999
        bubble.frame = CGRect(x: coordinate.x-25, y: coordinate.y-45, width: 50, height: 50 * 1.12)
        self.mapView.addSubview(bubble)
    }
    
    public func clearBubbles(isFrom: Bool = false, isAll: Bool = false) {
        if !isAll {
            let tag = isFrom ? 998 : 999
            let bubbles = self.mapView.subviews.filter { $0.tag == tag }
            for bubble in bubbles {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                    bubble.alpha = 0
                } completion: { flag in
                    if flag {
                        bubble.removeFromSuperview()
                    }
                }
            }
        } else {
            let bubbles = self.mapView.subviews.filter { $0.tag == 998 || $0.tag == 999 }
            for bubble in bubbles {
                bubble.removeFromSuperview()
            }
        }
    }
    
    public func drawRoute(_ drawingData: RouteDrawMetadata) {
        self.clearRoute()
        self.addTransparentView()
        let routeView = MapViewLayered(frame: self.mapView!.bounds)
        routeView.stations = mapOptions.stations.filter { drawingData.stationKeys.contains($0.key) }
        routeView.captions = mapOptions.captions.filter { drawingData.textsKeys.contains($0.key) }
        routeView.transitions = mapOptions.transitions.filter { drawingData.transfersKeys.contains($0.key) }
        routeView.connections  =  mapOptions.connections.filter { drawingData.connectionKeys.contains($0.key) }
        routeView.fromCoordinate = drawingData.fromCoordinate
        routeView.toCoordinate = drawingData.toCoordinate
        routeView.layer.setNeedsDisplay()
        
        self.mapView?.addSubview(routeView)
        var zoomRect = calculateRouteZoom(routeView.connections, routeView.captions)
        
        let newRect = zoomRect.applying(CGAffineTransform(scaleX: 1.3, y: 1.6))
        zoomRect.size.width = newRect.width
        zoomRect.size.height = newRect.height
        zoomRect.origin.x -= 50

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: [UIView.AnimationOptions.curveEaseInOut], animations: {
                self.zoom(to: zoomRect, animated: false)
            }, completion: nil)
        }
    }
    
    public func clearRoute() {
        let routeViews = self.mapView.subviews.filter {  $0.tag == 777 || $0 is MapViewLayered }
        routeViews.forEach { $0.removeFromSuperview() }
    }
}

extension MetroMapScrollView {
    
    private func imageForEmergency(_ status: Emergency.StationEmergency.Status) -> UIImage {
        switch status {
        case .closed:
            return UIImage(named: "closed_emergency", in: .mm_Map, compatibleWith: nil)!
        case .emergency:
            return UIImage(named: "emergency_emergency", in: .mm_Map, compatibleWith: nil)!
        case .info:
            return UIImage(named: "info_emergency", in: .mm_Map, compatibleWith: nil)!
        }
    }
    
    private func calculateRouteZoom(_ connections: [String: Any], _ captions: [String: TextDrawingData]) -> CGRect {
        let routeCGPath = CGMutablePath()
        connections.forEach {
            if let shapeData = $0.value as? ShapeDrawingData {
                routeCGPath.addPath(shapeData.path)
            }
        }
        routeCGPath.addRects(captions.values.map { $0.frame })
        return routeCGPath.boundingBoxOfPath
    }
    
    private func addTransparentView() {
        let transparentView = UIView(frame: self.mapView!.bounds)
        transparentView.backgroundColor = .mm_Base
        transparentView.alpha = 0.8
        transparentView.tag = 777
        self.mapView!.addSubview(transparentView)
    }
    
    private func drawMap() {
        self.mapView = MapViewLayered(frame: CGRect(origin: CGPoint.zero, size: mapOptions.mapSize))
        self.mapView?.additional = mapOptions.addtional
        self.mapView?.connections = mapOptions.connections
        self.mapView?.stations = mapOptions.stations
        self.mapView?.transitions = mapOptions.transitions
        self.mapView?.captions = mapOptions.captions
        self.mapView?.layer.setNeedsDisplay()
        self.mapView.layoutIfNeeded()
        self.mapView?.isUserInteractionEnabled = true
    }
    
    private func setup() {
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollView.DecelerationRate.normal
        self.backgroundColor = .mm_Base
        self.delegate = self
        self.contentInsetAdjustmentBehavior = .never
        self.contentSize =  mapOptions.mapSize
        self.maximumZoomScale = 2
        self.minimumZoomScale = 0.20
        self.contentMode = .center
        self.drawMap()
       
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.setupTaps()
        self.addSubview(mapView!)
    }
    
    private func setupTaps() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(tap:)))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(tap:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)
        mapView.addGestureRecognizer(singleTap)
    }
    
    @objc
    private func handleSingleTap(tap: UITapGestureRecognizer) {
        let touchPoint = tap.location(in: self.mapView)
        self.metroScrollDelegate?.onSingleTap(self, point: touchPoint)
    }
    
    @objc
    private func handleDoubleTap(tap: UITapGestureRecognizer) {
        if self.zoomScale == self.minimumZoomScale {
            self.zoom(to: zoomRectangle(scale: self.maximumZoomScale / 1.5, center: tap.location(in: tap.view)), animated: true)
        } else {
            self.setZoomScale(self.minimumZoomScale, animated: true)
        }
    }
    
    private func zoomRectangle(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = self.frame.size.height / scale
        zoomRect.size.width  = self.frame.size.width  / scale
        zoomRect.origin.x = center.x - (center.x * self.zoomScale)
        zoomRect.origin.y = center.y - (center.y * self.zoomScale)
        return zoomRect
    }
}

extension MetroMapScrollView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mapView
    }
}
