//
//  NewEmergencyCell.swift
//  MosmetroNew
//
//  Created by Кузин Павел on 03.08.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _Emergency {
    var leftIcon    : UIImage { get set }
    var title       : String  { get set }
    var description : String  { get set }
    var backgroundColor : UIColor { get set }
}

class NewEmergencyCell: UITableViewCell {
    
    private var color : UIColor? {
        didSet {
            guard let color = color else { return }
            self.updateColors(with: color)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard let color = color else { return }
        self.updateColors(with: color)
    }
    
    @IBOutlet weak private var container : UIView!
    @IBOutlet weak private var title     : UILabel!
    @IBOutlet weak private var subTitle  : UILabel!
    @IBOutlet weak private var leftImage : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.container.layer.borderWidth = 1
    }
    
    private func updateColors(with color: UIColor) {
        self.title.textColor             = color
        self.leftImage.tintColor         = color
        self.container.layer.borderColor = color.cgColor
    }
    
    public func configure(with data: _Emergency) {
        self.color           = data.backgroundColor
        self.title.text      = data.title
        self.subTitle.text   = data.description
        self.leftImage.image = data.leftIcon
    }
}
