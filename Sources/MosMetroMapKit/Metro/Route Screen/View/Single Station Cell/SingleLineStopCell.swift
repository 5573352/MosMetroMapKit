//
//  SingleLineStopCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 25.08.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

typealias Stop = (name: String, color: UIColor)

protocol _SingleStopCell {
    var name         : String  { get set }
    var lineIcon     : UIImage { get set }
    var firstStation : Stop    { get set }
    var isOutlined   : Bool    { get set }
    var timeToStop   : String  { get set }
}

class SingleLineStopCell : UITableViewCell {
        
    @IBOutlet weak var stopLabel     : UILabel!
    @IBOutlet weak var stationCircle : UIView!
    @IBOutlet weak var lineNameLabel : UILabel!
    @IBOutlet weak var lineIcon      : UIImageView!
    @IBOutlet weak var timeToStop    : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stationCircle.roundCorners(.all, radius: 5.5)
    }

    override func prepareForReuse() {
        self.stopLabel.text                = nil
        self.lineIcon.image                = nil
        self.timeToStop.text               = nil
        self.lineNameLabel.text            = nil
        self.stationCircle.backgroundColor = nil
    }
    
    public func configure(with data: _SingleStopCell) {
        self.stopLabel.text                = data.firstStation.name
        self.lineIcon.image                = data.lineIcon
        self.timeToStop.text               = data.timeToStop
        self.lineNameLabel.text            = data.name
        self.stationCircle.backgroundColor = data.firstStation.color
    }
}
