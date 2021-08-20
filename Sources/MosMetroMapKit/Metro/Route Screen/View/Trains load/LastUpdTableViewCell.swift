//
//  LastUpdTableViewCell.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 10.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _LastUpdTableViewCell {
    var color      : UIColor { get set }
    var lastUpdate : String  { get set }
}

class LastUpdTableViewCell : UITableViewCell {
    
    @IBOutlet weak var outSideView : UIView!
    @IBOutlet weak var inSideView  : UIView!
    @IBOutlet weak var infoLabel   : UILabel!
    
    override func prepareForReuse() {
        self.infoLabel.text = nil
    }
    
    public func configure(with data: _LastUpdTableViewCell) {
        self.infoLabel.text = data.lastUpdate
        self.inSideView.backgroundColor = data.color
        self.outSideView.backgroundColor = data.color
    }
}
