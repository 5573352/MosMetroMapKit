//
//  NewsStationCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 26.08.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class NewsStationCell: UITableViewCell {

    static let reuseID = "NewsStationCell"
    
    @IBOutlet weak var mainTitleLabel  : UILabel!
    @IBOutlet weak var lineImageView   : UIImageView!
    @IBOutlet weak var lineNameLabel   : UILabel!
    @IBOutlet weak var statusLabel     : UILabel!
    @IBOutlet weak var statusImageView : UIImageView!
    
    struct ViewState {
        let title           : String
        let lineIcon        : UIImage
        let lineName        : String
        let statusIcon      : UIImage
        let statusTintColor : UIColor
        let statusMessage   : String
    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }
}

extension NewsStationCell {

    func configure(_ data: ViewState) {
        self.mainTitleLabel.text       = data.title
        self.lineImageView.image       = data.lineIcon
        self.lineNameLabel.text        = data.lineName
        self.statusImageView.image     = data.statusIcon
        self.statusLabel.text          = data.statusMessage
        self.statusImageView.tintColor = data.statusTintColor
        self.statusLabel.textColor     = data.statusTintColor
    }
    
    func eraseData() {
        mainTitleLabel.text = nil
        lineNameLabel.text  = nil
        statusLabel.text    = nil
    }
    
    typealias T = ViewState
}
