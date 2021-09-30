//
//  StandartSubtitleCell.swift
//  MetroTest
//
//  Created by Сеня Римиханов on 15.12.2019.
//  Copyright © 2019 Гусейн Римиханов. All rights reserved.
//

import UIKit
import SDWebImage

protocol _StandartImageSubtitle {
    var image    : UIImage? { get set }
    var imageUrl : String?  { get set }
    var title    : String   { get set }
    var descr    : String   { get set }
}

class StandartImageSubtitleCell : UITableViewCell {
    
    @IBOutlet weak private var leftImage : UIImageView!
    @IBOutlet weak private var title     : UILabel!
    @IBOutlet weak private var secondary : UILabel!
    @IBOutlet weak private var separator : UIView!
    
    private var imageURL: String? {
        didSet {
            guard let urlStr = self.imageURL,
                let photoURL = URL(string: urlStr) else {
                self.leftImage.backgroundColor = .cardBackground
                self.leftImage.image = UIImage(named: "placholder_image")
                return
            }
            leftImage.sd_setImage(with: photoURL, placeholderImage: nil, options: [.scaleDownLargeImages]) { (image, error, cacheType, imageUrl) in
                if imageUrl != URL(string: urlStr),
                   error    != nil,
                   image    == nil {
                    self.leftImage.image = UIImage(named: "placholder_image")
                    self.leftImage.backgroundColor = .cardBackground
                }
            }
        }
    }
    
    override func awakeFromNib() {
        self.separator.roundCorners(.all, radius: 0.5)
    }
    
    override func prepareForReuse() {
        self.title.text      =  nil
        self.secondary.text  =  nil
        self.leftImage.image = nil
    }
    
    public func configure(with data: _StandartImageSubtitle, imageColor: UIColor = .mm_TextPrimary, restorise: Bool = false, corners: CGFloat = 0) {
        self.leftImage.roundCorners(.all, radius: corners)
        if let urlStr = data.imageUrl {
            self.imageURL = urlStr
        }
        if let image = data.image {
            self.leftImage.image = image
        }
        self.title.text     = data.title
        self.secondary.text = data.descr
        if restorise {
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    public func paymentSetup() {
        backgroundColor = .mm_TertiaryButton
        accessoryType   = .disclosureIndicator
        roundCorners(.all, radius: 10)
    }
}
