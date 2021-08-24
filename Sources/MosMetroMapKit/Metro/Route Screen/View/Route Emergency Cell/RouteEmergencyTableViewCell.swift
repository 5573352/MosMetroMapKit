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
    
    @IBOutlet weak var mainLabel : UILabel!
    @IBOutlet weak var seeMore : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainLabel.text = NSLocalizedString("Service changes on route", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        seeMore.text = NSLocalizedString("See more", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        self.mainView.roundCorners(.all, radius: 22)
    }
    
}
