//
//  StationBubble.swift
//
//  Created by Сеня Римиханов on 14.05.2020.
//

import UIKit

class BubbleSegmentView: UIView {
    
    let imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    var onTap: (() -> ())?
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                self.backgroundColor = UIColor.textPrimary.withAlphaComponent(0.05)
            } else {
                self.backgroundColor = .clear
            }
        }
    }
    convenience init(frame: CGRect, image: UIImage) {
        self.init(frame: frame)
        imgView.image = image
        self.layer.cornerRadius = 10
        self.addSubview(imgView)
        isUserInteractionEnabled = true
        imgView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imgView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imgView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imgView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc
    private func handleTap() {
        self.onTap?()
    }
}

class StationBubble: UIView {
    
    var onButtonTap: ((_ currentIndex: Int, _ direction: Direction) -> ())?
    var onSegmentSelect: ((Int) -> ())?
    
    struct ViewState        {
        let coordinates    : MapPoint
        let zoomRect       : CGRect
        let segments       : [Segment]
        let onButtonTap    : ((_ currentIndex: Int, _ direction: Direction) -> ())?
        
        struct Segment      {
            let image      : UIImage
            let isSelected : Bool
            let onSelect   : ((Int) -> ())?
        }
        
        static let initial = ViewState(coordinates: MapPoint(x: 0, y: 0), zoomRect: CGRect.zero, segments: [], onButtonTap: { (_,_) in})
    }
    
    
    var viewState: ViewState = .initial {
        didSet {
            render()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
         setup()
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let segmentsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.frame = CGRect(x: 2, y: 2, width: 256, height: 46)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let maskShape: CAShapeLayer = {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 11.86, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 11.8), controlPoint1: CGPoint(x: 5.31, y: 0), controlPoint2: CGPoint(x: 0, y: 5.28))
        bezierPath.addLine(to: CGPoint(x: 0, y: 37.38))
        bezierPath.addCurve(to: CGPoint(x: 11.86, y: 49.18), controlPoint1: CGPoint(x: 0, y: 43.9), controlPoint2: CGPoint(x: 5.31, y: 49.18))
        bezierPath.addLine(to: CGPoint(x: 116.96, y: 49.18))
        bezierPath.addLine(to: CGPoint(x: 128, y: 59.18))
        bezierPath.addCurve(to: CGPoint(x: 132, y: 59.18), controlPoint1: CGPoint(x: 129.13, y: 60.2), controlPoint2: CGPoint(x: 130.87, y: 60.2))
        bezierPath.addLine(to: CGPoint(x: 143.04, y: 49.18))
        bezierPath.addLine(to: CGPoint(x: 248.14, y: 49.18))
        bezierPath.addCurve(to: CGPoint(x: 260, y: 37.38), controlPoint1: CGPoint(x: 254.69, y: 49.18), controlPoint2: CGPoint(x: 260, y: 43.9))
        bezierPath.addLine(to: CGPoint(x: 260, y: 11.8))
        bezierPath.addCurve(to: CGPoint(x: 248.14, y: 0), controlPoint1: CGPoint(x: 260, y: 5.28), controlPoint2: CGPoint(x: 254.69, y: 0))
        bezierPath.addLine(to: CGPoint(x: 11.86, y: 0))
        bezierPath.close()
        bezierPath.usesEvenOddFillRule = true
        bezierPath.fill()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = UIColor.black.cgColor
        return shapeLayer
    }()
    
    private let lineSegmentsBackgroundView = BlurView(frame: CGRect(x: 0, y: 0, width: 260, height: 50), cornerRadius: 12)
    private let shadowView: UIView = {
       let view = UIView(frame: CGRect(x: 0, y: 70, width: 260, height: 48))
        view.backgroundColor = .cardBackground
        return view
    }()
    private let buttonsBackground = BlurView(frame: CGRect(x: 0, y: 70, width: 260, height: 60), cornerRadius: 0)
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 260, height: 50))
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    private let toButton = IconButton(.left, text: NSLocalizedString("To1", tableName: nil, bundle: .mm_Map, value: "", comment: ""), icon: UIImage(named: "route_to", in: .mm_Map, compatibleWith: nil)!, iconWidth: 20, iconHeight: 20)
    private let fromButton = IconButton(.left, text: NSLocalizedString("From1", tableName: nil, bundle: .mm_Map, value: "", comment: ""), icon: UIImage(named: "route_from", in: .mm_Map, compatibleWith: nil)!, iconWidth: 20, iconHeight: 20)
}

extension StationBubble {
    
    public func show(on view: UIView, scrollView: UIScrollView, position: MapPoint, with zoom: CGRect) {
        view.addSubview(self)
        self.alpha = 0
        let animation = VAAnimationType.from(direction: .top, offset: 30)
        UIView.animate(views: [self],
                       animations: [animation],
                       duration: 0.5)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: [UIView.AnimationOptions.allowUserInteraction,UIView.AnimationOptions.curveEaseIn], animations: {
                self.alpha = 1
                scrollView.zoom(to: zoom, animated: false)
            }, completion: nil)
        }
    }
    
    public func move(to point: MapPoint, on view: MetroMapScrollView, with zoom: CGRect) {
        self.frame = CGRect(x: point.x - 129.5, y: point.y - 130, width: 260, height: 130)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: [UIView.AnimationOptions.allowUserInteraction,UIView.AnimationOptions.curveEaseIn], animations: {
                view.zoom(to: zoom, animated: false)
            }, completion: nil)
        }
    }
    
    public func hide() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, options: [UIView.AnimationOptions.allowUserInteraction,UIView.AnimationOptions.curveEaseOut], animations: {
                self.alpha = 0
            }, completion: { [weak self] finished in
                guard let self = self else { return }
                if finished { self.removeFromSuperview() }
            })
        }
    }
}

// MARK: – Private methods
extension StationBubble {
    private func setup() {
        backgroundColor = .clear
        addSubview(lineSegmentsBackgroundView)
        addSubview(shadowView)
        shadowView.roundCorners(.all, radius: 12)
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.22
        shadowView.layer.shadowRadius = 12
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)

        addSubview(buttonsBackground)
        buttonsBackground.layer.mask = maskShape
        lineSegmentsBackgroundView.addSubview(segmentsStackView)
        buttonsBackground.contentView.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(fromButton)
        buttonsStackView.addArrangedSubview(toButton)
        fromButton.actionLabel.textColor = .textPrimary
        toButton.actionLabel.textColor = .textPrimary
        
      
        
        
        let fromTap = UITapGestureRecognizer(target: self, action: #selector(handleButtonTap(sender:)))
        fromTap.numberOfTapsRequired = 1
        let toTap = UITapGestureRecognizer(target: self, action: #selector(handleButtonTap(sender:)))
        toTap.numberOfTapsRequired = 1
        fromButton.addGestureRecognizer(fromTap)
        toButton.addGestureRecognizer(toTap)
    }
    
  
    
    private func render() {
        self.frame = CGRect(x: viewState.coordinates.x - 129.5, y: viewState.coordinates.y - 130, width: 260, height: 130)
        segmentsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if viewState.segments.count == 1 {
            lineSegmentsBackgroundView.isHidden = true
        } else {
            viewState.segments.enumerated().forEach { (index, item) in
                let bubbleSegment = BubbleSegmentView(frame: .zero, image: item.image)
                bubbleSegment.isSelected = item.isSelected
                bubbleSegment.onTap = { [weak self] in
                    guard let self = self else { return }
                    self.viewState.segments[index].onSelect?(index)
                }
                segmentsStackView.addArrangedSubview(bubbleSegment)
            }
        }
        
        
        guard let selectedIndex = viewState.segments.firstIndex(where: { $0.isSelected }) else { return }
        self.setSelected(index: selectedIndex)
    }
    
    private func setSelected(index: Int) {
        for (_index,segment) in self.segmentsStackView.arrangedSubviews.enumerated() {
            guard let _segment = segment as? BubbleSegmentView else { return }
            _segment.isSelected = _index == index ? true : false
            
        }
        
    }
    
    @objc
    private func handleButtonTap(sender: UITapGestureRecognizer) {
        guard let selectedIndex = viewState.segments.firstIndex(where: { $0.isSelected }) else { return }
        if sender.view == fromButton { self.viewState.onButtonTap?(selectedIndex,.from) } else { self.viewState.onButtonTap?(selectedIndex,.to) }
    }
    
    
    
    
}
