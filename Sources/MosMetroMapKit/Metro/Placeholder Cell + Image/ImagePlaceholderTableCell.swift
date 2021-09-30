//
//  ImagePlaceholderTableCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 09.09.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class ImagePlaceholderTableCell: UITableViewCell {

    static let reuseID = "ImagePlaceholderTableCell"

    @IBOutlet weak var placeholderSubtitleLabel : UILabel!
    @IBOutlet weak var placeholderTitleLabel    : UILabel!
    @IBOutlet weak var placeholderImageView     : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
