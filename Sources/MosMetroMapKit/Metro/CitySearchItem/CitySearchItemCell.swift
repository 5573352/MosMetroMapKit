//
//  CitySearchItemCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 11.06.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class CitySearchItemCell: UITableViewCell {
    
    static let reuseID = "CitySearchItemCell"

    @IBOutlet weak var dividerView    : UIView!
    @IBOutlet weak var leftImageView  : UIImageView!
    @IBOutlet weak var mainTitleLabel : UILabel!
    @IBOutlet weak var subtitleLabel  : UILabel!
    
    @IBOutlet weak var rightLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        dividerView.roundCorners(.all, radius: 0.5)
    }
}
