//
//  MCDTrainScheduleTableViewCell.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 15.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class MCDTrainScheduleTableViewCell: UITableViewCell {

    static let reuseID = "MCDTrainScheduleTableViewCell"
    
    @IBOutlet weak var statusLabel  : UILabel!
    @IBOutlet weak var timeLabel    : UILabel!
    @IBOutlet weak var deatilsLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}

extension MCDTrainScheduleTableViewCell {
    
    func setRedStatus() {
        statusLabel.textColor = .metroRed
    }
    
    func setGreenStatus() {
        statusLabel.textColor = .metroGreen
    }
}
