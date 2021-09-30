//
//  MosmetroNew
//
//  Created by Сеня Римиханов on 12.05.2020.
//

import UIKit

class MetroMapView : UIView, MetroMapScrollViewDelegate {
    
    func onSingleTap(_ scrollView: MetroMapScrollView, point: CGPoint) {
        self.onMapTap?(point)
    }

    public var metroMapScrollView : MetroMapScrollView!
    public lazy var stationSelectionView = StationSelectionView()
    
    public var onMapTap            : ((CGPoint)->())?
    public var onChatButtonTap     : (()->())?
    public var onFilterButtonTap   : (()->())?
    public var onSettingButtonTap  : (()->())?
    
    let blurEffect = UIBlurEffect(style: .prominent)
    
    var blurView: UIVisualEffectView!
    
    struct FieldState {
        let to   : StationSelectTextField.ViewState
        let from : StationSelectTextField.ViewState
    }
    
    enum SelectionViewState {
        case hidden
        case presented(FieldState)
    }
    
    enum BubbleState {
        case hidden
        case presented(StationBubble.ViewState)
    }
    
    enum RouteState {
        case hidden
        case presented(MetroRoutePreview.ViewState)
    }

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

extension MetroMapView {

    private func setup(mapOptions: MapDrawingOptions) {
        self.blurView = UIVisualEffectView(effect: blurEffect)
        
        self.metroMapScrollView = MetroMapScrollView(with: mapOptions)
        self.metroMapScrollView.metroScrollDelegate = self
        self.metroMapScrollView.pin(on: self, {[
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 0),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 0)
        ]})
        
        self.stationSelectionView.pin(on: self, {[
            $0.heightAnchor.constraint(equalToConstant: 44),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 16),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: -16),
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ]})
        
        self.blurView.alpha = 0.5
        self.blurView.pin(on: self, {[
            $0.heightAnchor.constraint(equalToConstant: 44),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 0)
        ]})
    }
    
    private func presentRoutePreview() {
        self.routePreview = MetroRoutePreview.loadFromNib()
        guard let _routePreview = routePreview else { return }
        _routePreview.pin(on: self, {[
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0)
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
        switch self.routeState {
        case .hidden:
            self.stationSelectionView.isHidden = false
            if let preview = self.routePreview {
                preview.removeFromSuperview()
                self.routePreview = nil
            }
            self.metroMapScrollView.clearRoute()
        case .presented(let state):
            self.stationSelectionView.isHidden = true
            if self.routePreview == nil {
                self.presentRoutePreview()
                self.routePreview?.viewState = state
            } else {
                self.routePreview?.removeFromSuperview()
                self.routePreview = nil
                self.presentRoutePreview()
                self.routePreview?.viewState = state
            }
        }
    }
}
