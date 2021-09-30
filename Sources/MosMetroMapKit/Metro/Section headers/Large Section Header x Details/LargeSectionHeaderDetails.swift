//
//  LargeSectionHeaderDetails.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 04.10.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import Foundation
import UIKit

class LargeSectionHeaderDetails: UIView {
    
    var onSelect: (() -> ())?
    
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func handleDetails(_ sender: UIButton) {
        self.onSelect?()
    }
    
}
