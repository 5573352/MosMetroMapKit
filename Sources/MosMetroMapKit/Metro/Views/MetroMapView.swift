//
//  MetroMapView.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 12.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

public struct FieldState {
    let to: StationSelectTextField.ViewState
    let from: StationSelectTextField.ViewState
}

public enum SelectionViewState {
    case hidden
    case presented(FieldState)
}

public enum BubbleState {
    case hidden
    case presented(StationBubble.ViewState)
}

public enum RouteState {
    case hidden
    case presented(MetroRoutePreview.ViewState)
}

public class MetroMapView: UIView {

    public var metroMapScrollView : MetroMapScrollView!
    public lazy var stationSelectionView = self.lazyStationSelectionView()
    
    public var onChatButtonTap     : (() -> ())?
    public var onDeeplinkButtonTap : (()->())?
    public var onFilterButtonTap   : (() -> ())?
    public var onSettingButtonTap  : (() -> ())?
    public var onMapTap            : ((CGPoint) -> ())?
    public var onStationSelectFromBubble: ((_ currentIndex: Int, _ direction: Direction) -> ())?
    public var onBubbleSegmentChange: ((_ segmentIndex: Int) -> ())?
    
    let blurEffect = UIBlurEffect(style: .prominent)
    
    var blurView: UIVisualEffectView!

    public var fieldsState: FieldState = FieldState(to: .initialFrom, from: .initialTo) {
        didSet {
            renderFields()
        }
    }
    
    public var routeState: RouteState = .hidden {
        didSet {
            renderRoute()
        }
    }
    
    public var bubbleState: BubbleState = .hidden {
        didSet {
            renderBubble()
        }
    }
    
    var routePreview: MetroRoutePreview?
    private var stationBubble: StationBubble?
    convenience init(frame: CGRect, mapDrawOptions: MapDrawingOptions) {
        self.init(frame: frame)
        setup(mapOptions: mapDrawOptions)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: PRIVATE METHODS
extension MetroMapView {

    private func setup(mapOptions: MapDrawingOptions) {
        self.blurView = UIVisualEffectView(effect: blurEffect)
        //MARK: SCROLL VIEW
        self.metroMapScrollView = MetroMapScrollView(with: mapOptions)
        self.metroMapScrollView.metroScrollDelegate = self
        metroMapScrollView.pin(on: self, {[
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 0),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 0),
            ]})
        
        //MARK: Blur View
        blurView.alpha = 0.5
        blurView.pin(on: self, {[
            $0.heightAnchor.constraint(equalToConstant: 44),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 0),
        ]})
    }
    
    private func presentRoutePreview() {
        routePreview = Bundle.main.loadNibNamed("ShortRoutePreview", owner: nil, options: nil)?.first as? MetroRoutePreview
        guard let _routePreview = routePreview else { return }
        addSubview(_routePreview)
        _routePreview.pin(on: self, {[
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
        ]})
    }

    public func updateStatusBarHeight(with height: CGFloat) {
        if let blur = self.blurView {
            blur.constraints.forEach {
                if $0.firstAttribute == NSLayoutConstraint.Attribute.height {
                    $0.constant = height
                    
                }
            }
        }
    }
    
    private func lazyStationSelectionView() -> StationSelectionView {
        let stationSelectionView = StationSelectionView()
        stationSelectionView.onTap = { [weak self] direction in
            guard let self = self else { return }
            //self.onTextFieldTap?(direction)
        }
        stationSelectionView.onClear = { [weak self] direction in
            guard let self = self else { return }
            //self.onTextFieldClear?(direction)
        }
        return stationSelectionView
    }

    private func renderFields() {
        self.stationSelectionView.fromTextField.viewState = self.fieldsState.from
        self.stationSelectionView.toTextField.viewState = self.fieldsState.to
    }
    
    private func renderBubble() {
        switch bubbleState {
        case .hidden:
            if let bubble = self.stationBubble {
                bubble.hide()
                self.stationBubble = nil
            }
        case .presented(let state):
            if let bubble = self.stationBubble {
                bubble.removeFromSuperview()
                self.stationBubble = nil
            }
            self.stationBubble = StationBubble()
            self.stationBubble?.viewState = state
            self.stationBubble?.show(on: self.metroMapScrollView.mapView, scrollView: self.metroMapScrollView, position: state.coordinates, with: state.zoomRect)
        }
    }
    
    private func renderRoute() {
        switch routeState {
        case .hidden:
            stationSelectionView.isHidden = false
            if let preview = self.routePreview {
                preview.removeFromSuperview()
                self.routePreview = nil
            }
            metroMapScrollView.clearRoute()
        case .presented(let state):
            self.stationSelectionView.isHidden = true
            if self.routePreview == nil {
                presentRoutePreview()
                self.routePreview?.viewState = state
            } else {
                routePreview?.removeFromSuperview()
                routePreview = nil
                presentRoutePreview()
                self.routePreview?.viewState = state
            }
        }
    }
}

// MARK: MetroMapScrollViewDelegate implementation
extension MetroMapView: MetroMapScrollViewDelegate {

    public func onSingleTap(_ scrollView: MetroMapScrollView, point: CGPoint) {
        self.onMapTap?(point)
    }
    
    public func onBubbleButtonTap(_ scrollView: MetroMapScrollView, direction: Direction, currentSegmentIndex: Int) {
        
    }
    
    public func onBubbleSegmentChange(_ scrollView: MetroMapScrollView, segmentIndex: Int) {
        self.onBubbleSegmentChange?(segmentIndex)
    }
    
    public func onStationTap(_ scrollView: MetroMapScrollView, station id: Int?) {
        
    }
}
