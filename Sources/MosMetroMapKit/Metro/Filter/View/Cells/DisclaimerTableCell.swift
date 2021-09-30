//
//  DisclaimerTableCell.swift
//
//  Created by Сеня Римиханов on 23.08.2020.
//
// swiftlint:disable all

import UIKit

class DisclaimerTableCell: UITableViewCell {
    
    static let reuseID = "DisclaimerTableCell"

    @IBOutlet weak var cardBackground: UIView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardBackground.roundCorners(.all, radius: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
