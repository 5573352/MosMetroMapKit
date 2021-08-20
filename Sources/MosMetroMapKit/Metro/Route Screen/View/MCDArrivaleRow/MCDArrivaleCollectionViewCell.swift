//
//  MCDArrivaleCollectionViewCell.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 16.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class MCDArrivaleCollectionViewCell: UICollectionViewCell {

    static let reuseID = "MCDArrivaleCollectionViewCell"
    
    @IBOutlet weak var detailsLabel     : UILabel!
    @IBOutlet weak var containerView    : UIView!
    @IBOutlet weak var arrivalTimeLabel : UILabel!
    
    private var hasSetTimer = false
    
    
    struct ViewState {
        enum Status {
            case early
            case standart
            case late
        }
        
        let arrivalTime : String
        let onSelect    : () -> ()
        let status      : Status
        let platform    : Int?
        let routeNumb   : Int
        
        static let initial = ViewState(arrivalTime: "", onSelect: {}, status: .standart, platform: 0, routeNumb: 000000)
    }
    
    var viewState: ViewState = .initial {
        didSet {
            arrivalTimeLabel.text = viewState.arrivalTime
            switch viewState.status {
            case .early:
                arrivalTimeLabel.textColor = .metroGreen
            case .standart:
                arrivalTimeLabel.textColor = .mm_TextPrimary
            case .late:
                arrivalTimeLabel.textColor = .metroRed
            }
            
            var detailsText = "№\(viewState.routeNumb)"
            if let platform = viewState.platform {
                detailsText = detailsText + " • \("pl.".localized())\(platform) "
            }
            detailsLabel.text = detailsText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.cardBackground
        self.roundCorners(.all, radius: 11)
    }
}
