//
//  MCDNearestTrainTableViewCell.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 22.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class MCDNearestTrainCell : UITableViewCell {
    
    @IBOutlet weak var outSideView  : UIView!
    @IBOutlet weak var inSideView   : UIView!
    @IBOutlet weak var cardView     : UIView!
    @IBOutlet weak var arrivalLabel : UILabel!
    @IBOutlet weak var detailsLabel : UILabel!
    
    private var hasSetTimer = false
    private var timer = Timer()
    
    var timeToTrain: Int! {
        didSet {
            if !hasSetTimer {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
                RunLoop.current.add(self.timer, forMode: RunLoop.Mode.common)
                hasSetTimer = true
            }
            arrivalLabel.text = "\("In".localized()) \(timeToTrain.asString(style: .abbreviated))"
        }
    }
    
    @objc
    private func updateTime() {
        if timeToTrain <= 0 {
            arrivalLabel.text = "Arrived".localized()
        } else {
            timeToTrain -= 1
        }
    }
    
    struct ViewState {
        let color     : UIColor
        let arrivalTime: String
        let onSelect: () -> ()
        let isStanding: Bool
        let details: String
        
        static let initial = ViewState(color: UIColor.clear, arrivalTime: "", onSelect: {}, isStanding: false, details: "")
    }
    
    var viewState: ViewState = .initial {
        didSet {
            outSideView.backgroundColor = viewState.color
            detailsLabel.text = viewState.details
            self.arrivalLabel.text = viewState.arrivalTime
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.roundCorners(.all, radius: 8)
        cardView.layer.borderColor = UIColor.grey.withAlphaComponent(0.2).cgColor
        cardView.layer.borderWidth = 1
        self.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        self.arrivalLabel.text = nil
        self.detailsLabel.text = nil
    }
    
    deinit {
        timer.invalidate()
    }
}
