//
//  InfoForSheduleTableViewCell.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 22.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _InfoForSheduleTableViewCell {
    var color : UIColor { get set }
    var info  : String  { get set }
}

class InfoForSheduleCell : UITableViewCell {

    @IBOutlet weak var lineView       : UIView!
    @IBOutlet weak var insideLineView : UIView!
    @IBOutlet weak var infoLabel      : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        self.infoLabel.text = NSLocalizedString("Nearest trains", tableName: nil, bundle: .mm_Map, value: "", comment: "")
    }

    override func prepareForReuse() {
        self.infoLabel.text = nil
    }
    
    public func configure(with data: _InfoForSheduleTableViewCell) {
        infoLabel.text                 = data.info
        lineView.backgroundColor       = data.color
        insideLineView.backgroundColor = .mm_Base
    }
}
