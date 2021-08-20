//
//  LineTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 29.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

protocol _LineTableViewCell {
    var name         : String   { get set }
    var lineIcon     : UIImage  { get set }
    var time         : String   { get set }
    var direction    : String   { get set }
    var wagon        : [Wagons] { get set }
    var advice       : String   { get set }
    var firstStation : Stop     { get set }
    var isOutlined   : Bool     { get set }
    var timeToStop   : String?  { get set }
}

class LineTableViewCell: UITableViewCell {

    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var linePathView: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var stationCircle: UIView!
    @IBOutlet weak var adviceLabel: UILabel!
    @IBOutlet weak var wagonsStackView: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var linePathMiddleView: UIView!
    @IBOutlet weak var timeToStop: UILabel!
    
    @IBOutlet weak var stopNameToDirectionLabel      : NSLayoutConstraint!
    @IBOutlet weak var stopNameToAdviceLabel         : NSLayoutConstraint!
    @IBOutlet weak var stationCircleToAdviceLabel    : NSLayoutConstraint!
    @IBOutlet weak var stationCircleToDirectionLabel : NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stationCircle.roundCorners(.all, radius: 5.5)
    }
    
    override func prepareForReuse() {
        self.timeLabel.text      = nil
        self.adviceLabel.text    = nil
        self.stopNameLabel.text  = nil
        self.mainTitleLabel.text = nil
        self.directionLabel.text = nil
    }

    fileprivate func handleWagons(_ data: _LineTableViewCell) {
        for wagon in data.wagon {
            switch wagon {
            case .all:
                wagonsStackView.arrangedSubviews.forEach {
                    if let imageView = $0 as? UIImageView {
                        imageView.tintColor = .mm_Main
                    }
                }
            case .first:
                if let first = wagonsStackView.arrangedSubviews[safe: 0] as? UIImageView {
                    first.tintColor = .mm_Main
                }
            case .nearFirst:
                if let second = wagonsStackView.arrangedSubviews[safe: 1] as? UIImageView {
                    second.tintColor = .mm_Main
                }
            case .center:
                if let middle = wagonsStackView.arrangedSubviews[safe: 2] as? UIImageView {
                    middle.tintColor = .mm_Main
                }
            case .nearEnd:
                if let fourth = wagonsStackView.arrangedSubviews[safe: 3] as? UIImageView {
                    fourth.tintColor = .mm_Main
                }
            case .end:
                if let last = wagonsStackView.arrangedSubviews.last as? UIImageView {
                    last.tintColor = .mm_Main
                }
            }
        }
    }
    
    public func configure(with data: _LineTableViewCell) {
        self.timeLabel.text                = data.time
        self.adviceLabel.text              = data.advice
        self.stopNameLabel.text            = data.firstStation.name
        self.mainTitleLabel.text           = data.name
        self.directionLabel.text           = data.direction
        self.leftImageView.image           = data.lineIcon
        self.adviceLabel.isHidden          = data.wagon.isEmpty ? true : false
        self.wagonsStackView.isHidden      = data.wagon.isEmpty ? true : false
        self.linePathMiddleView.isHidden   = data.isOutlined ? false : true
        self.linePathView.backgroundColor  = data.firstStation.color
        self.stationCircle.backgroundColor = data.firstStation.color
        if data.wagon.isEmpty {
            self.stopNameToAdviceLabel.priority         = .defaultLow
            self.stopNameToDirectionLabel.priority      = .defaultHigh
            self.stationCircleToAdviceLabel.priority    = .defaultLow
            self.stationCircleToDirectionLabel.priority = .defaultHigh
        } else {
            self.stopNameToAdviceLabel.priority         = .defaultHigh
            self.stopNameToDirectionLabel.priority      = .defaultLow
            self.stationCircleToAdviceLabel.priority    = .defaultHigh
            self.stationCircleToDirectionLabel.priority = .defaultLow
        }
        self.timeToStop.text = data.timeToStop
        self.handleWagons(data)
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
