//
//  UILabel+Extentions.swift
//
//  Created by Павел Кузин on 24.11.2020.
//

import UIKit

extension UILabel {

    //MARK: - SetLineSpacing for UILabel
    /**
    Sets space between lines in UILabel
    - Note: method sets **NSAttributedString** to **UILabel.text**
    - Parameters:
     * lineSpacing: CGFloat value  is included in the line fragment heights in the layout manager.
     * lineHeightMultiple: CGFloat value the natural line height of the receiver is multiplied by this factor (if positive) before being constrained by minimum and maximum line height. The default value of this property is 0.0.
     */
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        guard let labelText = self.text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
}
