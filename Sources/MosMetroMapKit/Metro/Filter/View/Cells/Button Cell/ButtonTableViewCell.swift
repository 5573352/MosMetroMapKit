//
//  ButtonTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 23.08.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
    
    static let reuseID = "ButtonTableViewCell"

    @IBOutlet weak var mainButton: MKButton!
    
    var onButtonTap: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainButton.roundCorners(.all, radius: 8)
        isUserInteractionEnabled = true
    }
    
    @IBAction func handleButtonTap(_ sender: Any) {
        self.onButtonTap?()
    }
    
}
