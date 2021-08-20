//
//  MCDLastUpdateTableViewCell.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 22.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _MCDLastUpdateTableViewCell {
    var color      : UIColor { get set }
    var lastUpdate : String  { get set }
}

class MCDLastUpdateCell : UITableViewCell {

    @IBOutlet weak var outSideView : UIView!
    @IBOutlet weak var inSideView  : UIView!
    @IBOutlet weak var infoLabel   : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        self.infoLabel.text = nil
    }
    
    public func configure(with data: _MCDLastUpdateTableViewCell) {
        self.infoLabel.text              = data.lastUpdate
        self.outSideView.backgroundColor = data.color
    }
}
