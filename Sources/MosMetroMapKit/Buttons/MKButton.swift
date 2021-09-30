//
//  MKButton.swift
//
//  Created by Сеня Римиханов on 18.10.2020.
//

import UIKit

class MKButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            self.isUserInteractionEnabled = isEnabled
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                guard let self = self else { return }
                self.alpha = self.isEnabled ? 1 : 0.4
            })
        }
    }
}

