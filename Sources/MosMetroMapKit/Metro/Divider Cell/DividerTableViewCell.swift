//
//  DividerTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 04.10.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class DividerTableViewCell: UITableViewCell {
    
    static let reuseID = "DividerTableViewCell"

    @IBOutlet weak var dividerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dividerView.alpha = 0.1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
