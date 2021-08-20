//
//  ValidationCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 23.07.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _ValidationCell {
    var image : UIImage { get set }
    var price : String  { get set }
    var title : String  { get set }
}

class ValidationCell : UITableViewCell {
    
    @IBOutlet weak var mainTitleLabel : UILabel!
    @IBOutlet weak var leftImageView  : UIImageView!
    @IBOutlet weak var rightLabel     : UILabel!
    
    public func configure(with data: _ValidationCell) {
        self.rightLabel.text     = data.price
        self.leftImageView.image = data.image
        self.mainTitleLabel.text = data.title
    }

    override func prepareForReuse() {
        self.rightLabel.text     = nil
        self.leftImageView.image = nil
        self.mainTitleLabel.text = nil
    }
}
