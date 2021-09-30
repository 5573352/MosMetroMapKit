//
//  SmallButtonTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 06.11.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class SmallButtonTableViewCell: UITableViewCell {
    
    static let reuseID = "SmallButtonTableViewCell"
    
    var onSelect: (() ->())?
    
    @IBOutlet weak var mainButton: UIButton!
    
    @IBAction func handleTap(_ sender: UIButton) {
        onSelect?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
