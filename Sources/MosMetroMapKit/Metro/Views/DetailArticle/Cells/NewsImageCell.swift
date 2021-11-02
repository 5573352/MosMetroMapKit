//
//  NewsImageCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 10.08.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _NewsImageCell {
    var imageURL : String { get set }
}

class NewsImageCell: UITableViewCell {
    
    static let reuseID = "NewsImageCell"
    
    var onSet: (()->())?

    @IBOutlet weak var mainImageView    : UIImageView!
    @IBOutlet var imageViewHeightAnchor : NSLayoutConstraint!
    
    var imageURL: String! {
        didSet {
            guard let photoURL = URL(string: imageURL) else { return }
            mainImageView.sd_setImage(with: photoURL) { [weak self] (image, error, _, _) in
                guard let self = self else { return }
                if let image = image {
                    print("SIZE - \(image.size)")
                    let scale = self.mainImageView.frame.width/image.size.width
                    let imageViewWidth = self.mainImageView.frame.width
                    let newImage = image.sd_resizedImage(with: CGSize(width: imageViewWidth * 2, height: (image.size.height * scale) * 2), scaleMode: .fill)
                    self.mainImageView.image = newImage
                    self.imageViewHeightAnchor.constant = image.size.height * scale
                    self.layoutSubviews()
                    self.onSet?()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainImageView.roundCorners(.all, radius: 8)
        mainImageView.layer.masksToBounds = true
    }
}
