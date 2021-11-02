//
//  Ext+CollectionViewCell.swift
//
//  Created by Кузин Павел on 22.06.2021.
//

import UIKit

public extension UICollectionViewCell {
    
    static var nib  : UINib{
        return UINib(nibName: identifire, bundle: .mm_Map)
    }
    
    static var identifire : String{
        return String(describing: self)
    }
}
