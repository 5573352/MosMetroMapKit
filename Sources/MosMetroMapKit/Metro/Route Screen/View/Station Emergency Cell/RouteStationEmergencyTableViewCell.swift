//
//  RouteStationEmergencyTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 11.11.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _RouteStationEmergencyTableViewCell {
    var hideDevider    : Bool    { get set }
    var stationName    : String  { get set }
    var line           : String  { get set }
    var lineIcon       : UIImage { get set }
    var emergencyTitle : String  { get set }
    var emergencyIcon  : UIImage { get set }
    var color          : UIColor { get set }
    var desc           : String  { get set }
}

class RouteStationEmergencyTableViewCell : UITableViewCell {
        
    @IBOutlet var stationLabel   : UILabel!
    @IBOutlet var lineImageView  : UIImageView!
    @IBOutlet var lineNameLabel  : UILabel!
    @IBOutlet var emergencyIcon  : UIImageView!
    @IBOutlet var emergencyDesc  : UILabel!
    @IBOutlet var dividerView    : UIView!
    @IBOutlet var emergencyLabel : UILabel!

    override func prepareForReuse() {
        self.stationLabel.text       = nil
        self.lineNameLabel.text      = nil
        self.emergencyDesc.text      = nil
        self.emergencyLabel.text     = nil
        self.emergencyIcon.image     = nil
        self.lineImageView.image     = nil
        self.emergencyIcon.tintColor = nil
    }
    
    public func configure(with data: _RouteStationEmergencyTableViewCell) {
        self.stationLabel.text       = data.stationName
        self.lineNameLabel.text      = data.line
        self.emergencyDesc.text      = data.desc
        self.emergencyLabel.text     = data.emergencyTitle
        self.emergencyIcon.image     = data.emergencyIcon
        self.lineImageView.image     = data.lineIcon
        self.dividerView.isHidden    = data.hideDevider
        self.emergencyIcon.tintColor = data.color
    }
}
