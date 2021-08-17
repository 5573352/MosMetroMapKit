//
//  Shadow.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 07.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

// MARK: – CoreImage shadow
public struct Shadow {
    let offset : CGSize
    let blur   : CGFloat
    let color  : UIColor
    
    public init(offset: CGSize, blur: CGFloat, color: UIColor) {
        self.offset = offset
        self.blur = blur
        self.color = color
    }
}
