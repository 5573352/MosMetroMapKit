//
//  FloatingButtonsView.swift
//
//  Created by Сеня Римиханов on 24.08.2020.
//

import UIKit

enum ButtonType {
    case main, secondary
}

protocol _FloatingButtons {
    var mainButtonTitle      : String { get set }
    var secondaryButtonTitle : String { get set }
    var onButtonTap    : ((ButtonType)->()) { get set }
}

class FloatingButtonsView: UIView {
    
    private var onButtonTap: ((ButtonType)->())?
    
    @IBOutlet weak private var mainButton      : UIButton!
    @IBOutlet weak private var secondaryButton : UIButton!

    @IBAction private func handleButtonTap(_ sender: UIButton) {
        switch sender {
        case mainButton:
            onButtonTap?(.main)
        case secondaryButton:
            onButtonTap?(.secondary)
        default:
            break
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.roundCorners(.all, radius: 12)
        self.mainButton.roundCorners(.all, radius: 8)
        self.secondaryButton.roundCorners(.all, radius: 8)
        self.setupShadows()
    }
    
    private func setupShadows() {
        self.layer.masksToBounds = false
        self.layer.borderWidth = 0.33
        self.layer.borderColor = UIColor.mm_TextSecondary.withAlphaComponent(0.08).cgColor
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    public func confugure(with data: _FloatingButtons) {
        self.mainButton.setTitle(data.mainButtonTitle, for: .normal)
        self.secondaryButton.setTitle(data.secondaryButtonTitle, for: .normal)
        self.onButtonTap = { button in
            switch button {
            case .main:
                data.onButtonTap(.main)
            case .secondary:
                data.onButtonTap(.secondary)
            }
        }
    }
}
