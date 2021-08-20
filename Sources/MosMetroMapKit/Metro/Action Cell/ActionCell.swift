//
//  ActionCell.swift
//  MetroTest
//
//  Created by Сеня Римиханов on 13.12.2019.
//  Copyright © 2019 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _ActionData {
    var color      : UIColor  { get set }
    var title      : String   { get set }
    var subtitle   : String   { get set }
    var rightImage : UIImage  { get set }
    var onSelect   : (()->()) { get set }
}

class ActionCell: UITableViewCell {
    
    @IBOutlet weak private var actionTextLabel: UILabel!
    @IBOutlet weak private var actionImage: UIImageView!
    
    override func awakeFromNib() {
        self.actionTextLabel.textColor = .mm_Main
        self.tintColor = .grey
        self.actionTextLabel.font = .mm_Headline_3
        self.contentView.backgroundColor = .clear
    }
    
    public func configure(with data: _ActionData) {
        self.actionImage.image = data.rightImage
        self.actionTextLabel.text = data.title
        self.actionTextLabel.textColor = data.color
    }
}
