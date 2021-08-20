//
//  RouteEmergencyTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 08.11.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class RouteEmergencyTableViewCell : UITableViewCell {
    
    @IBOutlet var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainView.roundCorners(.all, radius: 22)
    }
}
