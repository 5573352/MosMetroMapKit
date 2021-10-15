//
//  MCDLastStopTableViewCell.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 16.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class MCDLastStopTableViewCell: UITableViewCell {

    static let reuseID = "MCDLastStopTableViewCell"
    
    @IBOutlet weak var timeToStopLabel: UILabel!
    @IBOutlet weak var outsideLineView: UIView!
    @IBOutlet weak var insideLineView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var platformNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet var statusLabelToStation: NSLayoutConstraint!
    
    @IBOutlet var statusLabelToPlatform: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        circleView.roundCorners(.all, radius: 5.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
