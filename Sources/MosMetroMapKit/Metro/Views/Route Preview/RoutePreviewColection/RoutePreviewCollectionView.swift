//
//  RoutePreviewCollectionView.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 25.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol MainRoutePreviewCollectionViewDelegate: class {
    func didChangePage(_ page: Int)
    func scrollProgress(_ progress: CGFloat)
    func handleDetailsTap()
}

class RoutePreviewCollectionView : UICollectionView {
    
    weak var routeChangeDelegate: MainRoutePreviewCollectionViewDelegate?
    
    public var routesData = [RoutePreviewCollectionCell.ViewState]()
    
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        super.init(frame: frame, collectionViewLayout: layout)
        
        contentInsetAdjustmentBehavior = .always
        delegate = self
        dataSource = self
        isPagingEnabled = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        register(RoutePreviewCollectionCell.nib, forCellWithReuseIdentifier: RoutePreviewCollectionCell.identifire)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isOpaque = false
        clipsToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RoutePreviewCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return routesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoutePreviewCollectionCell.identifire, for: indexPath) as? RoutePreviewCollectionCell
        else { return UICollectionViewCell() }
        cell.viewState = routesData[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       
    }
}

extension RoutePreviewCollectionView: UICollectionViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.routeChangeDelegate?.scrollProgress(self.contentOffset.x / self.frame.size.width)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       let pageWidth = scrollView.frame.size.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        self.routeChangeDelegate?.didChangePage(currentPage)
    }
}

extension RoutePreviewCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: frame.height)
    }
}
