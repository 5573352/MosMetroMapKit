//
//  NewsTitleCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 10.08.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class NewsTitleCell: UITableViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainLabel.font = .mm_Headline_3
    }
}
