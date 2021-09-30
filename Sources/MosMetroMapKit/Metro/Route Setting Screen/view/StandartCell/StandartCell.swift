//
//  DefaultTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 23.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

public protocol _Standart {
    var font  : UIFont?  { get set }
    var title : String   { get set }
    var color : UIColor? { get set }
}

public class StandartCell : UITableViewCell {
    
    @IBOutlet weak private var title : UILabel!
    
    public func configure(with data: _Standart) {
        self.title.text          = data.title
        if let font  = data.font {
            self.title.font      = font
        }
        if let color = data.color {
            self.title.textColor = color
        }
    }
}
