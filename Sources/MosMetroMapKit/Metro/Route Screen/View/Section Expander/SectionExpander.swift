//
//  SectionExpander.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 29.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class SectionExpander: UIView {
    
    var onTap : (()->())?
    
    @IBOutlet weak var stationsCountLabel : UILabel!
    @IBOutlet weak var expandButton       : UIButton!
    @IBOutlet weak var linePathView       : UIView!
    @IBOutlet weak var chipView           : UIView!
    @IBOutlet weak var linePathMiddleView : UIView!
        
    var isExpanded: Bool! {
        didSet {
            if isExpanded {
                self.expandButton.setTitle("Hide".localized(), for: .normal)
            } else {
                self.expandButton.setTitle("Show".localized(), for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.expandButton.setTitle("Show".localized(), for: .normal)
        self.expandButton.setTitleColor(.mm_Main, for: .normal)
        self.expandButton.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        self.chipView.backgroundColor = .overlay
        self.chipView.roundCorners(.all, radius: 8)
    }

    @objc
    private func handleButtonTap() {
        self.onTap?()
    }
}
