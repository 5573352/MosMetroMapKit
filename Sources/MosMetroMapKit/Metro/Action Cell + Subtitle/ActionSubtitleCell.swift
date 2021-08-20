//
//  ActionSubtitleCell.swift
//  MetroTest
//
//  Created by Сеня Римиханов on 23.04.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _ActionSubtitleCell {
    var color      : UIColor  { get set }
    var title      : String   { get set }
    var subtitle   : String   { get set }
    var rightImage : UIImage  { get set }
    var onSelect   : (()->()) { get set }
}

class ActionSubtitleCell : UITableViewCell {
    
    @IBOutlet weak private var rightImageView : UIImageView!
    @IBOutlet weak private var mainTitleLabel : UILabel!
    @IBOutlet weak private var subTitleLabel  : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainTitleLabel.font = .mm_Headline_3
        self.subTitleLabel.font = .mm_Body_15_Regular
    }

    public func configure(with data: _ActionSubtitleCell) {
        self.rightImageView.image = data.rightImage
        self.rightImageView.tintColor = .mm_TextPrimary
        self.mainTitleLabel.text = data.title
        self.subTitleLabel.text = data.subtitle
        self.mainTitleLabel.textColor = data.color
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }

    public func eraseData() {
        self.mainTitleLabel.text = nil
        self.subTitleLabel.text = nil
    }
}
