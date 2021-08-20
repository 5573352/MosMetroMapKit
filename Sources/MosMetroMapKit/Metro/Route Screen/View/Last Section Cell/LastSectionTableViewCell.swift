//
//  LastSectionTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 28.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _LastSectionTableViewCell {
    var stop       : Stop    { get set }
    var isOutlined : Bool    { get set }
    var timeToStop : String? { get set }
}

class LastSectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stopCircle         : UIView!
    @IBOutlet weak var linePathView       : UIView!
    @IBOutlet weak var stopNameLabel      : UILabel!
    
    @IBOutlet weak var timeToStop         : UILabel!
    @IBOutlet weak var linePathMiddleView : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stopCircle.roundCorners(.all, radius: 5.5)
    }
    
    override func prepareForReuse() {
        self.timeToStop.text    = nil
        self.stopNameLabel.text = nil
    }
    
    public func configure(with data: _LastSectionTableViewCell) {
        self.timeToStop.text              = data.timeToStop
        self.stopNameLabel.text           = data.stop.name
        self.stopCircle.backgroundColor   = data.stop.color
        self.linePathMiddleView.isHidden  = data.isOutlined ? false : true
        self.linePathView.backgroundColor = data.stop.color
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
