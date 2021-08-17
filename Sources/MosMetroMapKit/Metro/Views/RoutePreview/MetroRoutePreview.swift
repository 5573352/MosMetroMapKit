//
//  MetroRoutePreview.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 14.09.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

public class MetroRoutePreview: UIView {
    
    @IBOutlet weak var fromImageView: UIImageView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toImageView: UIImageView!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var alertView: UIView!
    
    @IBOutlet weak var changeButton: UIButton!
    
    @IBOutlet weak var routesCollectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: CHIPageControlAji!
    
    @IBAction func handleClose(_ sender: UIButton) {
        viewState.onClose()
    }
    
    @IBAction func handleChange(_ sender: UIButton) {
        viewState.onChange()
    }
    
    
    public struct ViewState {
        let from: String
        let to: String
        let onPointSelect: (Direction) -> ()
        let onClose: () -> ()
        let onChange: () -> ()
        let onPageChange: (Int) -> ()
        let routes: [RoutePreviewCollectionCell.ViewState]
        
        static let initial = ViewState(from: "", to: "", onPointSelect: {_ in}, onClose: {}, onChange: {}, onPageChange: {_ in}, routes: [])
    }
    
    var viewState: ViewState = .initial {
        didSet {
            render()
        }
    }
    
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        routesCollectionView.dataSource = self
        routesCollectionView.delegate = self
        routesCollectionView.register(UINib(nibName: "RoutePreviewCollectionCell", bundle: nil), forCellWithReuseIdentifier: RoutePreviewCollectionCell.reuseID)
        let tapFrom = UITapGestureRecognizer(target: self, action: #selector(handlePointSelect(_:)))
        tapFrom.numberOfTapsRequired = 1
        let tapTo = UITapGestureRecognizer(target: self, action: #selector(handlePointSelect(_:)))
        tapTo.numberOfTapsRequired = 1
        fromLabel.isUserInteractionEnabled = true
        toLabel.isUserInteractionEnabled = true
        fromLabel.addGestureRecognizer(tapFrom)
        toLabel.addGestureRecognizer(tapTo)
        
        pageControl.numberOfPages = 1
        pageControl.borderWidth = 1
        pageControl.radius = 3.5
        pageControl.inactiveTransparency = 0
        pageControl.tintColor = .textPrimary
        pageControl.backgroundColor = .clear
        //self.pageControl.border
        pageControl.currentPageTintColor = .textPrimary
        alertView.roundCorners(.all, radius: 14)
        alertView.layer.masksToBounds = false
        
        
        
        alertView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
        alertView.layer.shadowOpacity = 1
        alertView.layer.shadowRadius = 11
        alertView.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
}

extension MetroRoutePreview {
    private func render() {
        pageControl.numberOfPages = viewState.routes.count
        routesCollectionView.reloadData()
        fromLabel.text = viewState.from
        toLabel.text = viewState.to
    }
    
    @objc
    private func handlePointSelect(_ sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel {
            if label === fromLabel {
                viewState.onPointSelect(.from)
            } else {
                viewState.onPointSelect(.to)
            }
        }
    }
}

extension MetroRoutePreview: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewState.routes.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoutePreviewCollectionCell.reuseID, for: indexPath) as! RoutePreviewCollectionCell
        cell.viewState = viewState.routes[indexPath.row]
        return cell
    }
    
    
}

extension MetroRoutePreview: UICollectionViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //print(self.contentOffset.x / self.frame.size.width)
        //(self.contentOffset.x / self.frame.size.width)
         self.pageControl.progress = Double((routesCollectionView.contentOffset.x / routesCollectionView.frame.size.width))
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = viewState.routes[safe: indexPath.row] else { return }
        item.onDetailsTap()
    }
    
    
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        viewState.onPageChange(currentPage)
    }
         
    
}

extension MetroRoutePreview: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: collectionView.frame.height)
        
    }
}
