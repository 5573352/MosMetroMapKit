//
//  LastUpdateTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 12.08.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _LastUpdate {
    var title : String { get set }
}

class LastUpdateTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var mainLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainLabel.font = .mm_Body_15_Regular
    }
    
    public func configure(with data: _LastUpdate) {
        self.mainLabel.text = data.title
    }
}
