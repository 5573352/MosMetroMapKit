//
//  ErrorTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 20.09.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _ErrorData {
    var title   : String   { get }
    var descr   : String   { get }
    var onRetry : (()->()) { get }
}

class ErrorTableViewCell: UITableViewCell {
    
    static let reuseID = "ErrorTableViewCell"

    @IBOutlet weak var errorTitle       : UILabel!
    @IBOutlet weak var errorDescLabel   : UILabel!
    @IBOutlet weak var errorRetryButton : UIButton!
    
    var onButtonTap: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        errorRetryButton.roundCorners(.all, radius: 8)
        errorRetryButton.setTitle(NSLocalizedString("Retry again", tableName: nil, bundle: .mm_Map, value: "", comment: ""), for: .normal)
    }
    
    public func configure(_ data: _ErrorData) {
        errorTitle.text      = data.title
        errorDescLabel.text  = data.descr
        onButtonTap          = data.onRetry
    }
    
    @IBAction func handleRetryTap(_ sender: UIButton) {
        onButtonTap?()
    }
}
