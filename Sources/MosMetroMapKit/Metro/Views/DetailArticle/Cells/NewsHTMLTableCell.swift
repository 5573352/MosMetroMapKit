//
//  NewsHTMLTableCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 02.09.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class NewsHTMLTableCell: UITableViewCell {
    
    static let reuseID = "NewsHTMLTableCell"

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
