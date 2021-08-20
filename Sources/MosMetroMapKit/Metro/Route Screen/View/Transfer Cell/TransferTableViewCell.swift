//
//  TransferTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 28.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _TransferTableViewCell {
    var image : UIImage { get set }
    var text  : String  { get set }
    var time  : String  { get set }
}

class TransferTableViewCell: UITableViewCell {
        
    @IBOutlet weak var leftImageView  : UIImageView!
    @IBOutlet weak var mainTitleLabel : UILabel!
    @IBOutlet weak var timeLabel      : UILabel!
    
    @IBOutlet var labelToSuperviewAnchor: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        timeLabel.text = nil
        mainTitleLabel.text = nil
    }
    
    public func configure(with data: _TransferTableViewCell) {
        timeLabel.text      = data.time
        mainTitleLabel.text = data.text
        leftImageView.image = data.image
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
