//
//  MKCenteredButton.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 20.10.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

@IBDesignable
class MKCenteredButtonViewWrapper : NibWrapperView<MKCenteredButton> { }

class MKCenteredButton: UIView {
    
    var onSelect: (() -> ())?
    
    var isEnabled: Bool = false {
        didSet {
            self.isUserInteractionEnabled = isEnabled
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                guard let self = self else { return }
                self.alpha = self.isEnabled ? 1 : 0.4
            })
        }
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
}

extension MKCenteredButton {

    private func setup() {
        self.roundCorners(.all, radius: 7)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handle(tap:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func handle(tap: UITapGestureRecognizer) {
        onSelect?()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 1.0
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 0.5
            }, completion: nil)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: nil)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: nil)
        }
    }
}
