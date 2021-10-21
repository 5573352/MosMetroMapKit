//
//  MCDExpandTableViewCell.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 15.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class MCDExpandTableViewCell: UITableViewCell {
    
    static let reuseID = "MCDExpandTableViewCell"

    @IBOutlet weak var arrowImageView : UIImageView!
    @IBOutlet weak var label     : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        label.text = NSLocalizedString("Previous", tableName: nil, bundle: .mm_Map, value: "", comment: "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
