//
//  SmallPlaceholderTableCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 04.10.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class SmallPlaceholderTableCell: UITableViewCell {
    
    static let reuseID = "SmallPlaceholderTableCell"

    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        descLabel.numberOfLines = 0;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }    
}
