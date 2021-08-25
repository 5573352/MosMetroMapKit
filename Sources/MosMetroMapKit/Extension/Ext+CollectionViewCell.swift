//
//  Ext+CollectionViewCell.swift
//  MosmetroNew
//
//  Created by Кузин Павел on 22.06.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit

public extension UICollectionViewCell {
    
    static var nib  : UINib{
        return UINib(nibName: identifire, bundle: .module)
    }
    
    static var identifire : String{
        return String(describing: self)
    }
}
