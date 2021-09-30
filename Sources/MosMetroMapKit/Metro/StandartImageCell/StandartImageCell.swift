//
//  DefaultImageCellTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 01.06.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _StandartImage {
    var title     : String   { get set }
    var leftImage : UIImage? { get set }
    var separator : Bool     { get set }
}

class StandartImageCell : UITableViewCell {
        
    @IBOutlet weak private var separator : UIView!
    @IBOutlet weak private var title     : UILabel!
    @IBOutlet weak private var leftImage : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
    }
    
    override func prepareForReuse() {
        self.title.text          = nil
        self.title.textColor     = nil
        self.leftImage.image     = nil
        self.leftImage.tintColor = nil
    }
    
    public func configure(with data: _StandartImage, imageColor: UIColor = .mm_TextPrimary, boldText: Bool = false, textColor: UIColor = .mm_TextPrimary) {
        self.title.text          = data.title
        self.leftImage.image     = data.leftImage
        self.separator.isHidden  = !data.separator
        self.leftImage.tintColor = imageColor
        self.title.textColor = textColor
        if boldText {
            self.title.font      = .mm_Body_17_Bold
        }
    }

}
