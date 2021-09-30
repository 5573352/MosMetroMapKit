//
//  PlaceholderTableCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 01.09.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class PlaceholderTableCell: UITableViewCell {
    
    static let reuseID = "PlaceholderTableCell"
    
    @IBOutlet weak var placeholderTitleLabel    : UILabel!
    @IBOutlet weak var placeholderSubtitleLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
