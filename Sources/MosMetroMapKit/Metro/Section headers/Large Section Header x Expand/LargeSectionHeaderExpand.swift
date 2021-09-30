//
//  LargeSectionHeaderExpand.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 08.10.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import Foundation
import UIKit

class LargeSectionHeaderExpand: UIView {
    
    var onTap: (() -> ())?
    
    var isExpanded: Bool! {
        didSet {
            UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                guard let self = self else { return }
                if self.isExpanded {
                    self.expandButton.layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat.pi))
                    
                } else {
                    self.expandButton.layer.setAffineTransform(CGAffineTransform(rotationAngle: 0))
                }
            })
        }
    }
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    
    @IBAction func handleExpand(_ sender: UIButton) {
        self.onTap?()
    }
}
