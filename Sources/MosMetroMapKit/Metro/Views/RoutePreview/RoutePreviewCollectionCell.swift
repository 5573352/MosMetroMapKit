//
//  RoutePreviewCollectionCell.swift
//  MetroTest
//
//  Created by Сеня Римиханов on 11.03.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import Foundation
import UIKit



class RoutePreviewCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var transitionAndCostLabel: UILabel!
    
    @IBOutlet weak var detailsButton: UILabel!
    
    
    struct ViewState {
        let time: String
        let subtitle: String
        let onDetailsTap: () -> ()
        let index: Int
        
        static let initial = ViewState(time: "", subtitle: "", onDetailsTap: {}, index: 0)
    }
    
    
    
    static let reuseID = "RoutePreviewCell"
    
    public var viewState: ViewState = .initial {
        didSet {
            render()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        detailsButton.text = "Route details".localized()
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .up
        addGestureRecognizer(swipeGesture)
    }
      
      override init(frame: CGRect) {
          super.init(frame: frame)
         
      }
      
      required init?(coder: NSCoder) {
          super.init(coder: coder)
      }
    
    private func setup() {
        
    }
    
    @objc
    private func handleSwipe() {
        self.viewState.onDetailsTap()
    }
    
   
    
}



extension RoutePreviewCollectionCell {
    private func render() {
        self.timeLabel.text = viewState.time
        self.transitionAndCostLabel.text = viewState.subtitle
        
    }
}
