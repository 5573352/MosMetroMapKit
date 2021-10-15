//
//  MCDStopTableViewCell.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 16.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class MCDStopTableViewCell: UITableViewCell {
    
    static let reuseID = "MCDStopTableViewCell"
    
    @IBOutlet weak var timeToStopLabel: UILabel!
    @IBOutlet weak var outsideLineView: UIView!
    @IBOutlet weak var insideLineView: UIView!
    @IBOutlet weak var outsideCircleView: UIView!
    @IBOutlet weak var insideCircleView: UIView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var platformNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet var statusLabelToStation: NSLayoutConstraint!
    
    @IBOutlet var statusLabelToPlatform: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        insideCircleView.roundCorners(.all, radius: 5.5)
        outsideCircleView.roundCorners(.all, radius: 5.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
