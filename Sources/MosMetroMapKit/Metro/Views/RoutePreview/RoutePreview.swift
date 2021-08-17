//
//  RoutePreview.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 25.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol RoutePreviewDelegate: class {
    func onRouteChange(_ routeIndex: Int)
    func clearRoute()
    func didTapDetails()
    
}

class RoutePreview: UIView {
    
    
    // Consts and vars
    weak var routePreviewDelegate: RoutePreviewDelegate?
    
    struct ViewState {
        let fromStation: String
        let toStation: String
        let onClear: () -> ()
        let onRouteChange: (Int) -> ()
        let routesData: [RoutePreviewCollectionCell.ViewState]
        
        static let initial = ViewState(fromStation: "Станция 1", toStation: "Станция 2", onClear: {}, onRouteChange: { _ in }, routesData: [])
    }
    
    public var viewState: ViewState = .initial {
        didSet {
            render()
        }
    }
    
    private let fromLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .BODY_S
        label.textColor = .textPrimary
        label.text = "От Раменки"
        return label
    }()
    
    private let toLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .BODY_S
        label.textColor = .textPrimary
        label.text = "До Славянский бульвар"
        return label
    }()
    
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(#imageLiteral(resourceName: "nav_close"), for: .normal)
        return button
    }()
    
    private let collectionView = RoutePreviewCollectionView(frame: .zero)
    
    let routePageControl: CHIPageControlAji = {
        let pageControl = CHIPageControlAji()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = 1
        pageControl.borderWidth = 1
        pageControl.radius = 3.5
        pageControl.inactiveTransparency = 0
        pageControl.tintColor = .textPrimary
        pageControl.backgroundColor = .clear
        //self.pageControl.border
        pageControl.currentPageTintColor = .textPrimary
        return pageControl
    }()
    
    
  
   
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RoutePreview {
    
    private func render() {
        self.fromLabel.text =  String.localizedStringWithFormat("From %@".localized(), viewState.fromStation)
        self.toLabel.text = String.localizedStringWithFormat("To %@".localized(), viewState.toStation)
        self.routePageControl.numberOfPages = viewState.routesData.count
        self.collectionView.routesData = viewState.routesData
        self.collectionView.reloadData()
    }
    
    private func setupViews() {
        addSubview(fromLabel)
        addSubview(toLabel)
        addSubview(collectionView)
        addSubview(closeButton)
        //backgroundColor = .orange
        addSubview(routePageControl)
        collectionView.routeChangeDelegate = self
        closeButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        
        // from label setup
        self.fromLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        self.fromLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        self.fromLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        // to label setup
        self.toLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        self.toLabel.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: 0).isActive = true
        self.toLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: toLabel.bottomAnchor, constant: 15).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        // close button setup
        
        closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 9).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        // page control settings
        
        routePageControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        routePageControl.heightAnchor.constraint(equalToConstant: 10).isActive = true
        routePageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10).isActive = true
        routePageControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        routePageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        addGradient()
        
    }
    
    @objc
    func close() {
        self.viewState.onClear()
        self.removeFromSuperview()
    }
    
    func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: -65, width: UIScreen.main.bounds.width, height: 260)
        gradientLayer.colors = [UIColor.MKBase.withAlphaComponent(0).cgColor,UIColor.MKBase.cgColor]
        gradientLayer.locations = [0,1]
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
   
}

extension RoutePreview: MainRoutePreviewCollectionViewDelegate {
    func handleDetailsTap() {
        //self.viewState.
    }
    
    func scrollProgress(_ progress: CGFloat) {
        self.routePageControl.progress = Double(progress)
    }
    
    func didChangePage(_ page: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            //self.pageControl.set(progress: page, animated: true)
            
            self.viewState.onRouteChange(page)
        })
        //self.pageControl.progress = Double(page)
        
    }
    
    
}

