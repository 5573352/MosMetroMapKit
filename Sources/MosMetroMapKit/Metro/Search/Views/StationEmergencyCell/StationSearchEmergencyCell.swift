//
//  StationSearchEmergencyCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 29.07.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

// swiftlint:disable all

class StationSearchEmergencyCell: UITableViewCell {
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var emergencyMessageLabel: UILabel!
    @IBOutlet weak var emergencyIcon: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainTitleLabel.font = .mm_Body_17_Bold
        subTitleLabel.font = .mm_Body_15_Regular
        emergencyMessageLabel.font = .mm_Body_15_Regular
    }
}
