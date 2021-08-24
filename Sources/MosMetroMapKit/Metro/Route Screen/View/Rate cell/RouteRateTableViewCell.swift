//
//  RouteRateTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 07.11.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _RouteRateTableViewCell {
    var onLike    : (()->()) { get set }
    var onDislike : (()->()) { get set }
}

class RouteRateTableViewCell : UITableViewCell {
        
    @NibWrapped(MKCenteredButton.self)
    @IBOutlet var likeButton    : UIView!
    @NibWrapped(MKCenteredButton.self)
    @IBOutlet var dislikeButton : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        likeButton.roundCorners(.all, radius: 7)
        dislikeButton.roundCorners(.all, radius: 7)
        _likeButton.titleLabel?.text        = NSLocalizedString("It`s okay", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        _dislikeButton.titleLabel?.text     = NSLocalizedString("So-so", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        _likeButton.iconImageView?.image    = #imageLiteral(resourceName: "like_hand")
        _dislikeButton.iconImageView?.image = #imageLiteral(resourceName: "dislike_hand")
    }

    override func prepareForReuse() {
        _likeButton.onSelect    = nil
        _dislikeButton.onSelect = nil
    }
    
    public func configure(with data: _RouteRateTableViewCell) {
        _likeButton.onSelect = { [weak self] in
            guard let self = self else { return }
            data.onLike()
            self._likeButton.isUserInteractionEnabled = false
            self._likeButton.backgroundColor = .metroGreen
            self._dislikeButton.isEnabled = false
        }
        _dislikeButton.onSelect = { [weak self] in
            guard let self = self else { return }
            data.onDislike()
            self._dislikeButton.isUserInteractionEnabled = false
            self._dislikeButton.backgroundColor = .metroRed
            self._likeButton.isEnabled = false
        }
    }
}
