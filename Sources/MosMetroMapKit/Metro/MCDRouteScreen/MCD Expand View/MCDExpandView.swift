//
//  MCDExpandView.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 22.06.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//


import UIKit

class MCDExpandView: UIView {
    
    @IBOutlet weak var stationsCountLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var chipView: UIView!
    @IBOutlet weak var miniCircle: UIView!
    @IBOutlet weak var topLinePathView: UIView!
    @IBOutlet weak var bottomLinePathView: UIView!
    @IBOutlet weak var topInnerLinePathView: UIView!
    @IBOutlet weak var bottomInnerLinePathView: UIView!
    @IBOutlet weak var hiddenPathView: UIView!
    
    @IBOutlet weak var topHeightAnchor: NSLayoutConstraint!
    @IBAction func handleExpand(_ sender: UIButton) {
        self.onTap?()
    }
    
    var onTap: (() -> ())?
    
    var isExpanded: Bool = false {
         didSet {
             if isExpanded {
                self.expandButton.setTitle(NSLocalizedString("Hide", tableName: nil, bundle: .mm_Map, value: "", comment: ""), for: .normal)
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
                    guard let self = self else { return }
                    self.hiddenPathView.alpha = 1
                }, completion: nil)
             } else {
                 self.expandButton.setTitle(NSLocalizedString("Show", tableName: nil, bundle: .mm_Map, value: "", comment: ""), for: .normal)
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
                    guard let self = self else { return }
                    self.hiddenPathView.alpha = 0
                }, completion: nil)
             }
         }
     }
    
    override func awakeFromNib() {
        setup()
    }
    
    private func setup() {
        expandButton.setTitle(NSLocalizedString("Show", tableName: nil, bundle: .mm_Map, value: "", comment: ""), for: .normal)
        expandButton.setTitleColor(.mainColor, for: .normal)
        chipView.roundCorners(.all, radius: 8)
        miniCircle.roundCorners(.all, radius: 1.5)
        topLinePathView.roundCorners(.bottom, radius: 2)
        bottomLinePathView.roundCorners(.top, radius: 2)
    }
}
