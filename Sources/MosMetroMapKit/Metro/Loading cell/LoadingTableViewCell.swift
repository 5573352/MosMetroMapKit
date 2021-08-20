//
//  LoadingTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 24.06.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
        
    @IBOutlet weak private var loadingSpinner : UIActivityIndicatorView!
    @IBOutlet weak private var loadingLabel   : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
    }
    
    override func prepareForReuse() {
        self.loadingLabel.text = nil
        loadingSpinner.startAnimating()
    }
    
    private func setupCell() {
        if #available(iOS 13.0, *) {
            self.loadingSpinner  .style = .medium
        }
        self.loadingSpinner.startAnimating()
        self.loadingLabel.text = "Loading...".localized()
    }
}
