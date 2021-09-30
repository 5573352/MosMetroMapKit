//
//  UIImageView.swift
//
//  Created by Павел Кузин on 24.11.2020.
//

import UIKit

extension UIImageView {
    /**
     Changes the tint color of the image inside imageview
     
     - Parameters:
       - **color**: the tint color to be set to the image.
     - Returns: a 9-part template image.
     */
    func setImageColor(_ color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
