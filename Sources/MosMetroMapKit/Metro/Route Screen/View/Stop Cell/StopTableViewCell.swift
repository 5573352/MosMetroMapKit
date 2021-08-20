//
//  StopTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 28.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _StopTableViewCell {
    var stop       : Stop    { get set }
    var isOutlined : Bool    { get set }
    var timeToStop : String? { get set }
}

class StopTableViewCell : UITableViewCell {
    
    @IBOutlet weak var stopCircle      : UIView!
    @IBOutlet weak var linePathView    : UIView!
    @IBOutlet weak var timeToStop      : UILabel!
    @IBOutlet weak var stopNameLabel   : UILabel!
    @IBOutlet weak var dividerLineView : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stopCircle.roundCorners(.all, radius: 4.5)
        self.stopCircle.layer.borderWidth = 2
        self.stopCircle.backgroundColor = .mm_Base
        self.linePathView.clipsToBounds = false
    }
    
    override func prepareForReuse() {
        self.timeToStop.text    = nil
        self.stopNameLabel.text = nil
    }

    public func configure(with data: _StopTableViewCell) {
        self.timeToStop.text              = data.timeToStop
        self.stopNameLabel.text           = data.stop.name
        self.dividerLineView.isHidden     = data.isOutlined ? false : true
        self.stopCircle.layer.borderColor = data.stop.color.cgColor
        self.linePathView.backgroundColor = data.stop.color
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
