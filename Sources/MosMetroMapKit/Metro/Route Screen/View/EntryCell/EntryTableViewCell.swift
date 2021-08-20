//
//  EntryTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 28.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _EntryTableViewCell {
    var image : UIImage { get set }
    var text  : String  { get set }
    var time  : String  { get set }
}

class EntryTableViewCell : UITableViewCell {
    
    @IBOutlet weak var leftimageView   : UIImageView!
    @IBOutlet weak var rightTitleLabel : UILabel!
    @IBOutlet weak var mainTitleLabel  : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainTitleLabel.textColor  = .mm_TextPrimary
        self.rightTitleLabel.textColor = .grey
    }
    
    override func prepareForReuse() {
        self.mainTitleLabel.text  = nil
        self.leftimageView.image  = nil
        self.rightTitleLabel.text = nil
    }
    
    public func configure(with data: _EntryTableViewCell) {
        self.leftimageView.image  = data.image
        self.mainTitleLabel.text  = data.text
        self.rightTitleLabel.text = data.time
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
