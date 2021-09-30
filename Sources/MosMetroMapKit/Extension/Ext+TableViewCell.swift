//
//  Ext+TableViewCell.swift
//
//  Created by Кузин Павел on 18.06.2021.
//

import UIKit

protocol _TransformAnimateCell: AnyObject {
    var transform : CGAffineTransform { get set }
    var alpha     : CGFloat           { get set }
    func transformAnimation()
    func undoTransformation()
}

extension _TransformAnimateCell {
    
    func transformAnimation() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.transform = .init(scaleX: 0.95, y: 0.95)
            self.alpha     = 0.8
        }
    }
    
    func undoTransformation() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.transform = .identity
            self.alpha     = 1
        }
    }
}

extension UITableViewCell {
    
    static var nib  : UINib{
        return UINib(nibName: identifire, bundle: .mm_Map)
    }
    
    static var identifire : String{
        return String(describing: self)
    }
}
