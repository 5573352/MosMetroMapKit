//
//  EmergencyCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 23.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class EmergencyCell: UITableViewCell {

    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var emergencyTitleLabel: UILabel!
    @IBOutlet weak private var emergencyDescriptionLabel: UILabel!
    @IBOutlet weak private var backgroundContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundContentView.roundCorners(.all, radius: 6)
        self.backgroundContentView.layer.masksToBounds = true
    }
}
