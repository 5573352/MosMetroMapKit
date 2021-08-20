//
//  LastUpdateWithLineTableViewCell.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 09.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _LastUpdateWithLineTableViewCell {
    var color : UIColor { get set }
    var info  : String  { get set }
}

class LastUpdateWithLineTableViewCell : UITableViewCell {
    
    @IBOutlet weak var lineView       : UIView!
    @IBOutlet weak var insideLineView : UIView!
    @IBOutlet weak var infoLabel      : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.infoLabel.text = "Ближайшие поезда и их загруженность".localized()
    }

    override func prepareForReuse() {
        self.infoLabel.text = nil
    }
    
    public func configure(with data: _LastUpdateWithLineTableViewCell) {
        self.infoLabel.text                 = data.info
        self.lineView.backgroundColor       = data.color
        self.insideLineView.backgroundColor = data.color
    }
}
